from fastapi import FastAPI, HTTPException, Depends, Header, Request
import os
import firebase_admin
from firebase_admin import credentials, auth, firestore, messaging
from pydantic import BaseModel
import numpy as np
import pandas as pd
import tensorflow as tf
import joblib
import yfinance as yf
import logging
import json
from datetime import datetime, timedelta

# Setup logger
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("stock_api")

app = FastAPI(title="GGRM Stock Prediction API")

# Firebase Admin initialization (optional)
FIREBASE_CRED = os.getenv("FIREBASE_CREDENTIALS") or os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
firebase_app = None
firestore_client = None
try:
    if FIREBASE_CRED:
        cred = credentials.Certificate(FIREBASE_CRED)
        firebase_app = firebase_admin.initialize_app(cred)
        firestore_client = firestore.client()
        logger.info("Firebase Admin berhasil diinisialisasi")
    else:
        logger.info("Tidak ada kredensial Firebase (env FIREBASE_CREDENTIALS tidak diset). Firebase dinonaktifkan.")
except Exception as e:
    logger.error(f"Inisialisasi Firebase gagal: {e}")
    firebase_app = None
    firestore_client = None

# Path model & scaler untuk GGRM
MODEL_PATH = "stock_model.keras"
SCALER_PATH = "scaler_ggrm.pkl"

# Initialize metadata dengan default value
metadata = {"info": "Model metadata tidak tersedia", "status": "loaded"}

# Load model & scaler
logger.info("Loading GGRM model and scaler...")
try:
    model = tf.keras.models.load_model(MODEL_PATH, compile=False)
    scaler = joblib.load(SCALER_PATH)
    
    # Load metadata jika ada
    metadata_path = 'model_metadata.json'
    if os.path.exists(metadata_path):
        try:
            with open(metadata_path, 'r') as f:
                metadata = json.load(f)
            logger.info(f"Model metadata: {metadata}")
        except Exception as e:
            logger.warning(f"Could not load metadata: {e}")
            metadata = {"info": "Metadata file tidak valid", "status": "fallback"}
    else:
        logger.info("Metadata file tidak ditemukan, menggunakan default")
        
    logger.info("Model dan scaler berhasil dimuat")
except FileNotFoundError as e:
    logger.error(f"File tidak ditemukan: {e}")
    metadata = {"error": f"File tidak ditemukan: {e}", "status": "error"}
    # Jangan raise exception di startup, biar API tetap jalan
except Exception as e:
    logger.error(f"Error loading model: {e}")
    metadata = {"error": str(e), "status": "error"}

# Feature columns untuk konsistensi
FEATURE_COLS = ['Close', 'Open', 'High', 'Low', 'Volume', 'return1', 'ma7', 'ma21', 'std7']
SEQ_LEN = 60
TICKER_DEFAULT = "GGRM.JK"

# Schema input untuk prediksi
class StockInput(BaseModel):
    open: float
    high: float
    low: float
    close: float
    volume: float
    return1: float = 0.0
    ma7: float = 0.0
    ma21: float = 0.0
    std7: float = 0.0

# Schema untuk sequence input
class SequenceInput(BaseModel):
    sequence: list  # 2D array (60, 9)

# Schema untuk user profile
class UserProfile(BaseModel):
    displayName: str = None
    phoneNumber: str = None
    fcmToken: str = None

# Schema untuk FCM notification
class FCMNotification(BaseModel):
    title: str
    body: str
    predictedClose: float = None
    ticker: str = "GGRM.JK"


def verify_id_token_optional(token: str):
    """Verify Firebase ID token"""
    try:
        decoded = auth.verify_id_token(token)
        return decoded
    except Exception as e:
        logger.warning(f"Verifikasi token gagal: {e}")
        raise HTTPException(status_code=401, detail="Invalid or expired token")


def get_current_user(authorization: str = Header(None)):
    """Dependency FastAPI: jika header Authorization disediakan, verifikasi token dan kembalikan decoded token. Jika tidak disediakan, kembalikan None."""
    if not authorization:
        return None
    if not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="Invalid Authorization header")
    token = authorization.split(" ", 1)[1]
    return verify_id_token_optional(token)


def fetch_stock_data(ticker: str = TICKER_DEFAULT, period: str = "1y") -> pd.DataFrame:
    """
    Fetch stock data dari yfinance
    """
    try:
        logger.info(f"Fetching {ticker} data for period {period}...")
        df = yf.download(ticker, period=period, interval="1d", progress=False)
        if df.empty:
            raise ValueError(f"No data returned for {ticker}")
        logger.info(f"Fetched {len(df)} rows for {ticker}")
        return df
    except Exception as e:
        logger.error(f"Error fetching {ticker}: {e}")
        raise


def engineer_features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Engineer technical features yang sama dengan training pipeline
    Columns: Close, Open, High, Low, Volume, return1, ma7, ma21, std7
    """
    df = df.copy()
    
    # Ensure required columns exist
    required = ['Open', 'High', 'Low', 'Close', 'Volume']
    if not all(col in df.columns for col in required):
        raise ValueError(f"Missing required columns: {required}")
    
    # Keep only required columns
    df = df[required].dropna()
    
    # Engineer features
    df['return1'] = df['Close'].pct_change(1)
    df['ma7'] = df['Close'].rolling(7).mean()
    df['ma21'] = df['Close'].rolling(21).mean()
    df['std7'] = df['Close'].rolling(7).std()
    
    # Drop NaN rows created by feature engineering
    df = df.dropna()
    
    logger.info(f"Engineered features shape: {df.shape}")
    return df


def prepare_prediction_data(ticker: str = TICKER_DEFAULT, lookback_days: int = 90) -> tuple:
    """
    Fetch data, engineer features, scale, dan siapkan untuk prediction
    Returns: (last_row_scaled, df, features_dict)
    """
    try:
        # Fetch data
        df = fetch_stock_data(ticker, period="3mo")
        
        # Engineer features
        df = engineer_features(df)
        
        if len(df) < SEQ_LEN:
            raise ValueError(f"Insufficient data: {len(df)} < {SEQ_LEN}")
        
        # Extract features dalam order yang sama seperti training
        features_array = df[FEATURE_COLS].values.astype(float)
        
        # Scale dengan scaler yang sudah disimpan
        features_scaled = scaler.transform(features_array)
        
        # Return latest row scaled + original dataframe + feature dict
        latest_features_dict = {col: float(df[col].iloc[-1]) for col in FEATURE_COLS}
        
        logger.info(f"Prepared prediction data: {features_scaled.shape}")
        return features_scaled, df, latest_features_dict
    
    except Exception as e:
        logger.error(f"Error preparing prediction data: {e}")
        raise


def predict_next_close(ticker: str = TICKER_DEFAULT) -> dict:
    """
    Predict next day close price menggunakan LSTM dengan data terbaru dari yfinance
    """
    try:
        features_scaled, df, features_dict = prepare_prediction_data(ticker)
        
        # Ambil last SEQ_LEN rows (sequence untuk LSTM)
        X = features_scaled[-SEQ_LEN:, :].reshape(1, SEQ_LEN, len(FEATURE_COLS))
        
        # Predict
        prediction_scaled = model.predict(X, verbose=0)
        
        # Inverse scale (hanya Close column - index 0)
        dummy = np.zeros((prediction_scaled.shape[0], len(FEATURE_COLS)))
        dummy[:, 0] = prediction_scaled[:, 0]
        prediction_unscaled = scaler.inverse_transform(dummy)
        predicted_close = float(prediction_unscaled[0, 0])
        
        # Get current close price
        current_close = float(df['Close'].iloc[-1])
        price_change = predicted_close - current_close
        pct_change = (price_change / current_close) * 100 if current_close != 0 else 0
        
        result = {
            "ticker": ticker,
            "current_close": current_close,
            "predicted_close": predicted_close,
            "price_change": price_change,
            "pct_change": pct_change,
            "confidence": "Medium",
            "timestamp": datetime.now().isoformat(),
            "last_update": str(df.index[-1].date())
        }
        
        logger.info(f"Prediction for {ticker}: {current_close} → {predicted_close} ({pct_change:+.2f}%)")
        return result
    
    except Exception as e:
        logger.error(f"Prediction error: {e}")
        raise


@app.get("/")
def root():
    return {
        "message": "GGRM Stock Prediction API 🚀",
        "ticker": "GGRM.JK",
        "model": "LSTM (60-day sequence, 9 features)",
        "endpoints": [
            "/docs - API Documentation (Swagger UI)",
            "/redoc - Alternative API Documentation",
            "/status - Model & API status (GET)",
            "/latest/{ticker} - Latest OHLCV + technical features (GET)",
            "/history/{ticker} - Historical data with features (GET)",
            "/predict - Predict with custom features (POST, needs auth)",
            "/predict-next - Predict next day close from yfinance data (POST, needs auth)",
            "/profile - User profile management (POST/GET, needs auth)",
            "/notify - Send FCM notification (POST, needs auth)"
        ],
        "features_used": ["Close", "Open", "High", "Low", "Volume", "return1", "ma7", "ma21", "std7"]
    }

@app.get("/status")
def get_status():
    """Status model dan informasi"""
    return {
        "model": "LSTM",
        "ticker": "GGRM.JK",
        "metadata": metadata,
        "scaler_type": "MinMaxScaler",
        "features": ["Close", "Open", "High", "Low", "Volume", "return1", "ma7", "ma21", "std7"]
    }

@app.post("/predict")
def predict_stock(data: StockInput, current_user: dict = Depends(get_current_user)):
    """
    Prediksi harga Close GGRM berdasarkan fitur yang diberikan
    Untuk backward compatibility dengan client yang sudah exist
    """
    try:
        features = np.array([[
            data.close, data.open, data.high, data.low, 
            data.volume, data.return1, data.ma7, data.ma21, data.std7
        ]])
        
        features_scaled = scaler.transform(features)
        prediction = model.predict(features_scaled, verbose=0)
        
        # Scale kembali ke nilai asli
        dummy = np.zeros((prediction.shape[0], len(FEATURE_COLS)))
        dummy[:, 0] = prediction[:, 0]
        prediction_unscaled = scaler.inverse_transform(dummy)
        
        result = {
            "predicted_close": float(prediction_unscaled[0, 0]),
            "confidence": "Medium",
            "timestamp": datetime.now().isoformat()
        }

        # Jika Firestore tersedia dan ada user yang terautentikasi, simpan log prediksi
        try:
            if firestore_client and current_user:
                doc = {
                    "uid": current_user.get("uid"),
                    "email": current_user.get("email"),
                    "ticker": "GGRM.JK",
                    "input": features.tolist(),
                    "predicted_close": float(prediction_unscaled[0, 0]),
                    "timestamp": datetime.utcnow().isoformat()
                }
                firestore_client.collection("predictions").add(doc)
        except Exception as e:
            logger.warning(f"Gagal menyimpan log prediksi ke Firestore: {e}")

        return result
    except Exception as e:
        logger.error(f"Prediction error: {e}")
        return {"error": str(e), "status": "failed"}


@app.post("/predict-next")
def predict_next(ticker: str = TICKER_DEFAULT, current_user: dict = Depends(get_current_user)):
    """
    Prediksi harga Close hari berikutnya menggunakan data terbaru dari yfinance
    Menggunakan LSTM dengan sequence length 60 hari
    """
    try:
        result = predict_next_close(ticker)
        
        # Log ke Firestore jika ada user terautentikasi
        try:
            if firestore_client and current_user:
                doc = {
                    "uid": current_user.get("uid"),
                    "email": current_user.get("email"),
                    "ticker": ticker,
                    "current_close": result["current_close"],
                    "predicted_close": result["predicted_close"],
                    "price_change": result["price_change"],
                    "pct_change": result["pct_change"],
                    "timestamp": datetime.utcnow().isoformat()
                }
                firestore_client.collection("predictions").add(doc)
        except Exception as e:
            logger.warning(f"Gagal menyimpan log ke Firestore: {e}")
        
        return result
    except Exception as e:
        logger.error(f"Predict next error: {e}")
        return {"error": str(e), "status": "failed", "ticker": ticker}

@app.get("/latest/{ticker}")
def get_latest_data(ticker: str = TICKER_DEFAULT):
    """
    Ambil data GGRM terbaru dari Yahoo Finance dengan engineered features
    """
    try:
        logger.info(f"Fetching latest data untuk {ticker}...")
        df = fetch_stock_data(ticker, period="3mo")
        df = engineer_features(df)
        
        if df.empty:
            return {"error": f"No data found for {ticker}", "ticker": ticker}
        
        latest = df.iloc[-1]
        
        return {
            "ticker": ticker,
            "date": str(df.index[-1].date()),
            "ohlcv": {
                "open": float(latest['Open']),
                "high": float(latest['High']),
                "low": float(latest['Low']),
                "close": float(latest['Close']),
                "volume": float(latest['Volume'])
            },
            "technical_features": {
                "return1": float(latest['return1']),
                "ma7": float(latest['ma7']),
                "ma21": float(latest['ma21']),
                "std7": float(latest['std7'])
            }
        }
    except Exception as e:
        logger.error(f"Error fetching latest data: {e}")
        return {"error": str(e), "ticker": ticker}


@app.get("/history/{ticker}")
def get_stock_history(
    ticker: str = TICKER_DEFAULT, 
    period: str = "1mo", 
    interval: str = "1d"
):
    """
    Ambil histori harga saham dari Yahoo Finance dengan engineered features
    Contoh: /history/GGRM.JK?period=1y&interval=1d
    Period: 1d, 5d, 1mo, 3mo, 6mo, 1y, 2y, 5y, 10y, ytd, max
    """
    try:
        logger.info(f"Fetching history untuk {ticker}, period={period}...")
        df = yf.download(ticker, period=period, interval=interval, progress=False)
        
        if df.empty:
            return {"error": f"No data found for {ticker}", "ticker": ticker}
        
        # Engineer features
        df = engineer_features(df)
        
        history = []
        for idx, row in df.iterrows():
            history.append({
                "date": str(idx.date()),
                "ohlcv": {
                    "open": float(row["Open"]),
                    "high": float(row["High"]),
                    "low": float(row["Low"]),
                    "close": float(row["Close"]),
                    "volume": float(row["Volume"])
                },
                "technical_features": {
                    "return1": float(row["return1"]),
                    "ma7": float(row["ma7"]),
                    "ma21": float(row["ma21"]),
                    "std7": float(row["std7"])
                }
            })
        
        return {
            "ticker": ticker,
            "period": period,
            "interval": interval,
            "data_points": len(history),
            "history": history
        }
    except Exception as e:
        logger.error(f"Error fetching history: {e}")
        return {"error": str(e), "ticker": ticker}

@app.post("/profile")
def create_or_update_profile(profile: UserProfile, current_user: dict = Depends(get_current_user)):
    """
    Buat atau update profil user di Firestore
    Memerlukan autentikasi Firebase
    """
    if not current_user:
        raise HTTPException(status_code=401, detail="Autentikasi diperlukan")
    
    uid = current_user.get("uid")
    email = current_user.get("email")
    
    try:
        if firestore_client:
            user_data = {
                "uid": uid,
                "email": email,
                "updatedAt": datetime.utcnow().isoformat()
            }
            
            # Tambah field opsional jika disediakan
            if profile.displayName:
                user_data["displayName"] = profile.displayName
            if profile.phoneNumber:
                user_data["phoneNumber"] = profile.phoneNumber
            if profile.fcmToken:
                user_data["fcmToken"] = profile.fcmToken
            
            # Check apakah user sudah ada
            user_ref = firestore_client.collection("users").document(uid)
            existing = user_ref.get()
            
            if existing.exists:
                # Update existing
                user_ref.update(user_data)
                user_data["createdAt"] = existing.get("createdAt")
            else:
                # Buat baru
                user_data["createdAt"] = user_data["updatedAt"]
                user_ref.set(user_data)
            
            return {"success": True, "data": user_data}
        else:
            return {"success": False, "error": "Firestore tidak tersedia"}
    except Exception as e:
        logger.error(f"Error updating profile: {e}")
        return {"success": False, "error": str(e)}


@app.get("/profile")
def get_profile(current_user: dict = Depends(get_current_user)):
    """
    Ambil profil user dari Firestore
    Memerlukan autentikasi Firebase
    """
    if not current_user:
        raise HTTPException(status_code=401, detail="Autentikasi diperlukan")
    
    uid = current_user.get("uid")
    
    try:
        if firestore_client:
            user_ref = firestore_client.collection("users").document(uid)
            user_doc = user_ref.get()
            
            if user_doc.exists:
                return user_doc.to_dict()
            else:
                return {
                    "uid": uid,
                    "email": current_user.get("email"),
                    "message": "Profil belum dibuat. Gunakan POST /profile untuk membuat."
                }
        else:
            return {"error": "Firestore tidak tersedia"}
    except Exception as e:
        logger.error(f"Error getting profile: {e}")
        return {"error": str(e)}


@app.post("/notify")
def send_fcm_notification(notification: FCMNotification, current_user: dict = Depends(get_current_user)):
    """
    Kirim FCM notification ke semua device user yang terdaftar
    Memerlukan autentikasi Firebase
    """
    if not current_user:
        raise HTTPException(status_code=401, detail="Autentikasi diperlukan")
    
    uid = current_user.get("uid")
    
    try:
        if not firebase_admin or not firestore_client:
            return {"success": False, "error": "Firebase tidak diinisialisasi"}
        
        # Ambil semua user dengan fcmToken
        users_ref = firestore_client.collection("users")
        docs = users_ref.stream()
        
        sent_count = 0
        
        for doc in docs:
            user_data = doc.to_dict()
            fcm_token = user_data.get("fcmToken")
            
            if fcm_token:
                try:
                    # Buat message dengan data payload
                    message_data = {
                        "title": notification.title,
                        "body": notification.body,
                        "ticker": notification.ticker,
                    }
                    
                    if notification.predictedClose:
                        message_data["predictedClose"] = str(notification.predictedClose)
                    
                    msg = messaging.Message(
                        notification=messaging.Notification(
                            title=notification.title,
                            body=notification.body
                        ),
                        data=message_data,
                        token=fcm_token
                    )
                    
                    # Send message
                    messaging.send(msg)
                    sent_count += 1
                    logger.info(f"FCM sent ke {user_data.get('email')}")
                except Exception as e:
                    logger.warning(f"Gagal kirim FCM ke {user_data.get('email')}: {e}")
        
        return {
            "success": True,
            "message": f"Notifikasi berhasil dikirim ke {sent_count} device",
            "sentTo": sent_count
        }
    except Exception as e:
        logger.error(f"Error sending FCM: {e}")
        return {"success": False, "error": str(e)}

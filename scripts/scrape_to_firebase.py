"""
Script untuk scraping data dari yfinance dan menyimpan ke Firebase Firestore
Usage: python scrape_to_firebase.py
"""

import os
import firebase_admin
from firebase_admin import credentials, firestore
import yfinance as yf
import pandas as pd
import logging
from datetime import datetime

# Setup logger
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("scrape_firebase")

# Firebase credentials path
# Cek environment variable atau gunakan default path
FIREBASE_CRED_PATH = os.getenv("FIREBASE_CREDENTIALS") or os.getenv("GOOGLE_APPLICATION_CREDENTIALS")

# Default path jika environment variable tidak diset
if not FIREBASE_CRED_PATH:
    default_paths = [
        "Secret/stock-prediction-realtime-firebase-adminsdk-fbsvc-6d0f85bf5b.json",
        "google-services.json",
        "Secret/firebase-adminsdk.json"
    ]
    for path in default_paths:
        if os.path.exists(path):
            FIREBASE_CRED_PATH = path
            break

# Ticker yang akan di-scrape
TICKERS = ["GGRM.JK", "BBRI.JK", "TLKM.JK", "UNVR.JK", "ASII.JK"]

def init_firebase():
    """Initialize Firebase Admin SDK"""
    if not FIREBASE_CRED_PATH:
        raise ValueError("Environment variable FIREBASE_CREDENTIALS tidak diset")
    
    if not os.path.exists(FIREBASE_CRED_PATH):
        raise ValueError(f"File kredensial tidak ditemukan: {FIREBASE_CRED_PATH}")
    
    cred = credentials.Certificate(FIREBASE_CRED_PATH)
    firebase_admin.initialize_app(cred)
    firestore_client = firestore.client()
    logger.info("Firebase berhasil diinisialisasi")
    return firestore_client

def fetch_stock_data(ticker: str, period: str = "1y") -> pd.DataFrame:
    """Fetch stock data dari yfinance"""
    try:
        logger.info(f"Fetching {ticker} data...")
        df = yf.download(ticker, period=period, interval="1d", progress=False)
        if df.empty:
            logger.warning(f"No data for {ticker}")
            return None
        logger.info(f"Fetched {len(df)} rows for {ticker}")
        return df
    except Exception as e:
        logger.error(f"Error fetching {ticker}: {e}")
        return None

def save_to_firestore(firestore_client, ticker: str, df: pd.DataFrame):
    """Simpan data stock ke Firestore"""
    try:
        collection_name = "stock_data"
        
        # Hapus data lama untuk ticker ini
        logger.info(f"Deleting old data for {ticker}...")
        docs = firestore_client.collection(collection_name).where("ticker", "==", ticker).stream()
        for doc in docs:
            doc.reference.delete()
        
        # Simpan data baru per tanggal
        logger.info(f"Saving {len(df)} records to Firestore...")
        batch = firestore_client.batch()
        
        for idx, row in df.iterrows():
            doc_data = {
                "ticker": ticker,
                "date": idx.strftime("%Y-%m-%d"),
                "open": float(row["Open"]) if hasattr(row["Open"], '__float__') else float(row["Open"].iloc[0]),
                "high": float(row["High"]) if hasattr(row["High"], '__float__') else float(row["High"].iloc[0]),
                "low": float(row["Low"]) if hasattr(row["Low"], '__float__') else float(row["Low"].iloc[0]),
                "close": float(row["Close"]) if hasattr(row["Close"], '__float__') else float(row["Close"].iloc[0]),
                "volume": float(row["Volume"]) if hasattr(row["Volume"], '__float__') else float(row["Volume"].iloc[0]),
                "adj_close": float(row.get("Adj Close", row["Close"])) if "Adj Close" in row else float(row["Close"]),
                "scraped_at": datetime.utcnow().isoformat()
            }
            
            doc_id = f"{ticker}_{idx.strftime('%Y%m%d')}"
            doc_ref = firestore_client.collection(collection_name).document(doc_id)
            batch.set(doc_ref, doc_data)
        
        # Commit batch
        batch.commit()
        logger.info(f"Successfully saved {len(df)} records for {ticker}")
        return True
        
    except Exception as e:
        logger.error(f"Error saving {ticker} to Firestore: {e}")
        return False

def save_prediction_to_firestore(firestore_client, ticker: str, prediction_data: dict):
    """Simpan hasil prediksi ke Firestore"""
    try:
        doc_ref = firestore_client.collection("predictions").document()
        doc_ref.set({
            **prediction_data,
            "ticker": ticker,
            "created_at": datetime.utcnow().isoformat()
        })
        logger.info(f"Prediction saved: {prediction_data.get('predicted_close', 'N/A')}")
        return True
    except Exception as e:
        logger.error(f"Error saving prediction: {e}")
        return False

def main():
    """Main function untuk scraping dan upload ke Firebase"""
    logger.info("="*50)
    logger.info("Starting scrape to Firebase...")
    logger.info("="*50)
    
    # Initialize Firebase
    try:
        firestore_client = init_firebase()
    except Exception as e:
        logger.error(f"Failed to initialize Firebase: {e}")
        return
    
    # Scrape setiap ticker
    success_count = 0
    for ticker in TICKERS:
        logger.info(f"\n{'='*30}")
        logger.info(f"Processing {ticker}...")
        logger.info(f"{'='*30}")
        
        # Fetch data
        df = fetch_stock_data(ticker, period="1y")
        
        if df is not None and not df.empty:
            # Simpan ke Firestore
            if save_to_firestore(firestore_client, ticker, df):
                success_count += 1
                logger.info(f"✅ {ticker} - {len(df)} records saved to Firestore")
            else:
                logger.error(f"❌ {ticker} - Failed to save to Firestore")
        else:
            logger.error(f"❌ {ticker} - No data fetched")
    
    logger.info(f"\n{'='*50}")
    logger.info(f"Scraping complete! Success: {success_count}/{len(TICKERS)}")
    logger.info(f"{'='*50}")

if __name__ == "__main__":
    main()


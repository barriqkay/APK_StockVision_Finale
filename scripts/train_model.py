import yfinance as yf
import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from sklearn.preprocessing import MinMaxScaler
import joblib
import logging
from datetime import datetime, timedelta

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Konfigurasi
TICKER = "GGRM.JK"   # saham Gudang Garam
PERIOD = "5y"
SEQ_LEN = 60
HORIZON = 1
MAX_RETRIES = 3
RETRY_DELAY = 2

def fetch_and_prepare(ticker=TICKER, period=PERIOD):
    """
    Fetch data GGRM dari Yahoo Finance dan prepare sequences untuk LSTM
    dengan error handling dan retry logic
    """
    logger.info(f"Fetching data untuk {ticker} dengan periode {period}...")
    
    df = None
    for attempt in range(MAX_RETRIES):
        try:
            df = yf.download(ticker, period=period, interval="1d", progress=False)
            if not df.empty:
                logger.info(f"Data berhasil diunduh: {len(df)} rows")
                break
        except Exception as e:
            logger.warning(f"Attempt {attempt + 1} failed: {e}")
            if attempt < MAX_RETRIES - 1:
                import time
                time.sleep(RETRY_DELAY)
    
    if df is None or df.empty:
        raise RuntimeError(f"Gagal mengunduh data {ticker} setelah {MAX_RETRIES} percobaan")

    # Pastikan kolom ada
    required_cols = ['Open', 'High', 'Low', 'Close', 'Volume']
    if not all(col in df.columns for col in required_cols):
        raise ValueError(f"Data tidak memiliki kolom: {required_cols}")

    df = df[required_cols].dropna()
    logger.info(f"Data setelah cleanup: {len(df)} rows")

    # Tambah fitur teknikal
    df['return1'] = df['Close'].pct_change(1)
    df['ma7'] = df['Close'].rolling(7).mean()
    df['ma21'] = df['Close'].rolling(21).mean()
    df['std7'] = df['Close'].rolling(7).std()
    df = df.dropna()
    
    logger.info(f"Data setelah feature engineering: {len(df)} rows")

    # Normalisasi features
    features = ['Close', 'Open', 'High', 'Low', 'Volume', 'return1', 'ma7', 'ma21', 'std7']
    data = df[features].values.astype(float)
    
    # Scale data menggunakan MinMaxScaler
    scaler = MinMaxScaler()
    data_scaled = scaler.fit_transform(data)
    
    # Simpan scaler untuk inference
    joblib.dump(scaler, 'scaler_ggrm.pkl')
    logger.info("Scaler disimpan ke scaler_ggrm.pkl")
    
    # Prepare targets
    targets = df['Close'].shift(-HORIZON).values.astype(float)

    # Hapus baris dengan target NaN
    idx = np.where(~np.isnan(targets))[0]
    data_scaled = data_scaled[idx, :]
    targets = targets[idx]
    
    logger.info(f"Shapes → data: {data_scaled.shape}, targets: {targets.shape}")

    # Create sequences
    X, y = [], []
    for i in range(SEQ_LEN, len(data_scaled)):
        X.append(data_scaled[i-SEQ_LEN:i])
        y.append(targets[i])
    
    X = np.array(X)
    y = np.array(y)
    
    logger.info(f"Final shapes → X: {X.shape}, y: {y.shape}")
    return X, y, df, scaler

if __name__ == "__main__":
    try:
        # Ambil data GGRM
        X, y, df_full, scaler = fetch_and_prepare()
        logger.info(f"Data siap untuk training: X={X.shape}, y={y.shape}")

        # Split data
        train_size = int(len(X) * 0.8)
        X_train, X_test = X[:train_size], X[train_size:]
        y_train, y_test = y[:train_size], y[train_size:]
        
        logger.info(f"Train shapes: X={X_train.shape}, y={y_train.shape}")
        logger.info(f"Test shapes: X={X_test.shape}, y={y_test.shape}")

        # Bangun model LSTM untuk GGRM
        logger.info("Building LSTM model untuk prediksi GGRM...")
        model = Sequential([
            LSTM(128, return_sequences=True, input_shape=(X.shape[1], X.shape[2])),
            Dropout(0.2),
            LSTM(64, return_sequences=True),
            Dropout(0.2),
            LSTM(32),
            Dropout(0.2),
            Dense(16, activation='relu'),
            Dense(1)
        ])

        model.compile(optimizer='adam', loss='mse', metrics=['mae'])
        logger.info(model.summary())

        # Training model
        logger.info("Memulai training...")
        history = model.fit(
            X_train, y_train,
            epochs=50,
            batch_size=32,
            validation_data=(X_test, y_test),
            verbose=1
        )

        # Evaluasi
        logger.info("Mengevaluasi model...")
        train_loss, train_mae = model.evaluate(X_train, y_train, verbose=0)
        test_loss, test_mae = model.evaluate(X_test, y_test, verbose=0)
        
        logger.info(f"Train Loss: {train_loss:.6f}, MAE: {train_mae:.6f}")
        logger.info(f"Test Loss: {test_loss:.6f}, MAE: {test_mae:.6f}")

        # Simpan model
        model.save("stock_model.keras", save_format="keras")
        logger.info("Model disimpan ke stock_model.keras")
        
        # Simpan metadata
        metadata = {
            'ticker': TICKER,
            'trained_date': datetime.now().isoformat(),
            'data_rows': len(df_full),
            'seq_len': SEQ_LEN,
            'train_loss': float(train_loss),
            'test_loss': float(test_loss)
        }
        import json
        with open('model_metadata.json', 'w') as f:
            json.dump(metadata, f, indent=2)
        logger.info("Metadata disimpan ke model_metadata.json")
        
    except Exception as e:
        logger.error(f"Error dalam training: {e}", exc_info=True)
        raise


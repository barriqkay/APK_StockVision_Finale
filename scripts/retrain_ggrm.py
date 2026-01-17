"""
Script untuk retrain model GGRM dengan data terbaru dari Yahoo Finance
Bisa dijalankan secara berkala (scheduled task) untuk update model
"""

import yfinance as yf
import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from sklearn.preprocessing import MinMaxScaler
import joblib
import logging
import json
from datetime import datetime
import sys

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Konfigurasi
TICKER = "GGRM.JK"
PERIOD = "5y"
SEQ_LEN = 60
HORIZON = 1
EPOCHS = 50
BATCH_SIZE = 32

def fetch_ggrm_data(ticker=TICKER, period=PERIOD):
    """Fetch data GGRM dari Yahoo Finance"""
    logger.info(f"Fetching {ticker} data untuk {period}...")
    
    try:
        df = yf.download(ticker, period=period, interval="1d", progress=False)
        
        if df.empty:
            raise ValueError(f"No data returned for {ticker}")
        
        logger.info(f"✅ Downloaded {len(df)} rows untuk {ticker}")
        print(f"DEBUG: Data shape = {df.shape}")
        print(f"DEBUG: First row:\n{df.head(1)}")
        print(f"DEBUG: Last row:\n{df.tail(1)}")
        return df
        
    except Exception as e:
        logger.error(f"❌ Error fetching data: {e}")
        print(f"ERROR: {e}")
        raise

def prepare_data(df, seq_len=SEQ_LEN, horizon=HORIZON):
    """Prepare data untuk training LSTM"""
    logger.info("Preparing data...")
    
    # Gunakan Close price
    data = df[['Close']].values.astype(float)
    
    # Normalize
    scaler = MinMaxScaler(feature_range=(0, 1))
    data_scaled = scaler.fit_transform(data)
    
    # Create sequences
    X, y = [], []
    for i in range(len(data_scaled) - seq_len - horizon + 1):
        X.append(data_scaled[i:(i + seq_len)])
        y.append(data_scaled[i + seq_len + horizon - 1])
    
    X = np.array(X)
    y = np.array(y)
    
    # Split train-test (80-20)
    split = int(len(X) * 0.8)
    X_train, X_test = X[:split], X[split:]
    y_train, y_test = y[:split], y[split:]
    
    logger.info(f"✅ Data prepared: X_train={X_train.shape}, X_test={X_test.shape}")
    
    return X_train, X_test, y_train, y_test, scaler

def build_model(seq_len=SEQ_LEN, input_shape=1):
    """Build LSTM model"""
    logger.info("Building LSTM model...")
    
    model = Sequential([
        LSTM(50, activation='relu', input_shape=(seq_len, input_shape), return_sequences=True),
        Dropout(0.2),
        LSTM(50, activation='relu'),
        Dropout(0.2),
        Dense(25, activation='relu'),
        Dense(1)
    ])
    
    model.compile(optimizer='adam', loss='mse', metrics=['mae'])
    logger.info("✅ Model built successfully")
    
    return model

def train_model(model, X_train, y_train, X_test, y_test, epochs=EPOCHS, batch_size=BATCH_SIZE):
    """Train model"""
    logger.info(f"Training model for {epochs} epochs...")
    
    history = model.fit(
        X_train, y_train,
        epochs=epochs,
        batch_size=batch_size,
        validation_data=(X_test, y_test),
        verbose=1
    )
    
    logger.info("✅ Training completed")
    return history

def evaluate_model(model, X_test, y_test):
    """Evaluate model"""
    logger.info("Evaluasi model...")
    
    test_loss, test_mae = model.evaluate(X_test, y_test, verbose=0)
    train_loss, train_mae = model.evaluate(X_test[:int(len(X_test)*0.8)], 
                                          y_test[:int(len(y_test)*0.8)], verbose=0)
    
    metrics = {
        'train_loss': float(train_loss),
        'train_mae': float(train_mae),
        'test_loss': float(test_loss),
        'test_mae': float(test_mae)
    }
    
    logger.info(f"Train Loss: {train_loss:.6f}, MAE: {train_mae:.6f}")
    logger.info(f"Test Loss: {test_loss:.6f}, MAE: {test_mae:.6f}")
    
    return metrics

def save_model_and_scaler(model, scaler, model_path="stock_model.keras", scaler_path="scaler_ggrm.pkl"):
    """Save model dan scaler"""
    logger.info("Saving model dan scaler...")
    
    model.save(model_path)
    joblib.dump(scaler, scaler_path)
    
    logger.info(f"✅ Model saved to {model_path}")
    logger.info(f"✅ Scaler saved to {scaler_path}")

def main():
    """Main training pipeline"""
    try:
        logger.info("="*60)
        logger.info("GGRM MODEL RETRAINING PIPELINE")
        logger.info("="*60)
        
        # Fetch data
        df = fetch_ggrm_data(TICKER, PERIOD)
        
        # Prepare data
        X_train, X_test, y_train, y_test, scaler = prepare_data(df, SEQ_LEN, HORIZON)
        
        # Build model
        model = build_model(SEQ_LEN, input_shape=1)
        
        # Train model
        history = train_model(model, X_train, y_train, X_test, y_test, EPOCHS, BATCH_SIZE)
        
        # Evaluate model
        metrics = evaluate_model(model, X_test, y_test)
        
        # Save model
        save_model_and_scaler(model, scaler)
        
        # Save metrics
        with open('model_metadata.json', 'w') as f:
            json.dump({
                'ticker': TICKER,
                'period': PERIOD,
                'seq_len': SEQ_LEN,
                'horizon': HORIZON,
                'epochs': EPOCHS,
                'batch_size': BATCH_SIZE,
                'metrics': metrics,
                'trained_at': datetime.now().isoformat()
            }, f, indent=2)
        
        logger.info("="*60)
        logger.info("✅ Training selesai! Model GGRM berhasil diupdate")
        logger.info(f"Metrics: {metrics}")
        logger.info("="*60)
        
    except Exception as e:
        logger.error(f"❌ Error dalam training: {e}", exc_info=True)
        raise

if __name__ == "__main__":
    main()
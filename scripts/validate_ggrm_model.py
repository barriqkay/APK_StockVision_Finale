"""
Script untuk test dan validasi model GGRM
Cek akurasi model dengan data test
"""

import numpy as np
import pandas as pd
import tensorflow as tf
import joblib
import yfinance as yf
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import logging
import json
from datetime import datetime, timedelta
import matplotlib.pyplot as plt

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

TICKER = "GGRM.JK"
SEQ_LEN = 60
HORIZON = 1

def load_model_and_data():
    """Load model, scaler, dan metadata"""
    logger.info("Loading model dan resources...")
    
    try:
        model = tf.keras.models.load_model("stock_model.keras", compile=False)
        scaler = joblib.load("scaler_ggrm.pkl")
        
        with open('model_metadata.json', 'r') as f:
            metadata = json.load(f)
        
        logger.info("Model dan resources berhasil dimuat")
        return model, scaler, metadata
        
    except FileNotFoundError as e:
        logger.error(f"File tidak ditemukan: {e}")
        raise

def fetch_test_data(ticker=TICKER, period="6mo"):
    """Fetch data GGRM untuk testing"""
    logger.info(f"Fetching test data untuk {ticker}...")
    
    df = yf.download(ticker, period=period, interval="1d", progress=False)
    
    if df.empty:
        raise ValueError(f"No data for {ticker}")
    
    logger.info(f"Downloaded {len(df)} rows")
    return df

def prepare_test_sequences(df, scaler):
    """Prepare test sequences"""
    logger.info("Preparing test sequences...")
    
    df = df[['Open', 'High', 'Low', 'Close', 'Volume']].dropna()
    
    # Feature engineering
    df['return1'] = df['Close'].pct_change(1)
    df['ma7'] = df['Close'].rolling(7).mean()
    df['ma21'] = df['Close'].rolling(21).mean()
    df['std7'] = df['Close'].rolling(7).std()
    df = df.dropna()
    
    features = ['Close', 'Open', 'High', 'Low', 'Volume', 'return1', 'ma7', 'ma21', 'std7']
    data = df[features].values.astype(float)
    
    # Scale dengan scaler yang sama
    data_scaled = scaler.transform(data)
    
    # Targets
    targets = df['Close'].shift(-HORIZON).values.astype(float)
    
    idx = np.where(~np.isnan(targets))[0]
    data_scaled = data_scaled[idx, :]
    targets = targets[idx]
    
    # Create sequences
    X, y = [], []
    for i in range(SEQ_LEN, len(data_scaled)):
        X.append(data_scaled[i-SEQ_LEN:i])
        y.append(targets[i])
    
    X = np.array(X)
    y = np.array(y)
    
    logger.info(f"Test shapes → X: {X.shape}, y: {y.shape}")
    
    return X, y, df.iloc[SEQ_LEN+np.arange(len(y))]

def evaluate_model(model, scaler, X_test, y_test, df_test):
    """Evaluate model performance"""
    logger.info("Evaluating model...")
    
    # Predictions
    y_pred = model.predict(X_test, verbose=0)
    
    # Inverse transform untuk error metrics (compare dengan actual prices)
    dummy_test = np.zeros((X_test.shape[0], 9))
    dummy_test[:, 0] = y_test
    y_test_actual = scaler.inverse_transform(dummy_test)[:, 0]
    
    dummy_pred = np.zeros((y_pred.shape[0], 9))
    dummy_pred[:, 0] = y_pred.squeeze()
    y_pred_actual = scaler.inverse_transform(dummy_pred)[:, 0]
    
    # Metrics
    mse = mean_squared_error(y_test_actual, y_pred_actual)
    mae = mean_absolute_error(y_test_actual, y_pred_actual)
    rmse = np.sqrt(mse)
    r2 = r2_score(y_test_actual, y_pred_actual)
    
    # Percentage error
    mape = np.mean(np.abs((y_test_actual - y_pred_actual) / y_test_actual)) * 100
    
    logger.info("=" * 50)
    logger.info("MODEL PERFORMANCE METRICS")
    logger.info("=" * 50)
    logger.info(f"MSE:  {mse:.6f}")
    logger.info(f"MAE:  {mae:.6f}")
    logger.info(f"RMSE: {rmse:.6f}")
    logger.info(f"R²:   {r2:.6f}")
    logger.info(f"MAPE: {mape:.2f}%")
    logger.info("=" * 50)
    
    return {
        'mse': float(mse),
        'mae': float(mae),
        'rmse': float(rmse),
        'r2': float(r2),
        'mape': float(mape)
    }, y_test_actual, y_pred_actual

def test_recent_predictions():
    """Test predictions untuk data terbaru"""
    logger.info("\n" + "=" * 50)
    logger.info("RECENT PRICE PREDICTIONS")
    logger.info("=" * 50)
    
    model, scaler, _ = load_model_and_data()
    
    # Fetch recent data
    df = yf.download(TICKER, period="3mo", interval="1d", progress=False)
    df = df[['Open', 'High', 'Low', 'Close', 'Volume']].dropna()
    
    df['return1'] = df['Close'].pct_change(1)
    df['ma7'] = df['Close'].rolling(7).mean()
    df['ma21'] = df['Close'].rolling(21).mean()
    df['std7'] = df['Close'].rolling(7).std()
    df = df.dropna()
    
    features = ['Close', 'Open', 'High', 'Low', 'Volume', 'return1', 'ma7', 'ma21', 'std7']
    data = df[features].values.astype(float)
    data_scaled = scaler.transform(data)
    
    # Last sequence
    last_seq = data_scaled[-SEQ_LEN:]
    
    # Predict next day
    X_input = np.array([last_seq])
    pred_scaled = model.predict(X_input, verbose=0)[0, 0]
    
    # Inverse transform
    dummy = np.zeros((1, 9))
    dummy[0, 0] = pred_scaled
    pred_price = scaler.inverse_transform(dummy)[0, 0]
    
    current_price = df['Close'].iloc[-1]
    change = pred_price - current_price
    change_pct = (change / current_price) * 100
    
    logger.info(f"Harga GGRM hari ini: Rp {current_price:,.0f}")
    logger.info(f"Prediksi besok:      Rp {pred_price:,.0f}")
    logger.info(f"Perubahan:           Rp {change:,.0f} ({change_pct:+.2f}%)")
    logger.info("=" * 50)
    
    return {
        'current_price': float(current_price),
        'predicted_price': float(pred_price),
        'change': float(change),
        'change_percent': float(change_pct),
        'date': str(df.index[-1].date())
    }

def main():
    try:
        # Load model
        model, scaler, metadata = load_model_and_data()
        
        logger.info(f"Metadata: {json.dumps(metadata, indent=2)}")
        
        # Fetch test data
        df = fetch_test_data(period="6mo")
        
        # Prepare test sequences
        X_test, y_test, df_test = prepare_test_sequences(df, scaler)
        
        # Evaluate
        metrics, y_actual, y_pred = evaluate_model(model, scaler, X_test, y_test, df_test)
        
        # Test recent predictions
        recent = test_recent_predictions()
        
        # Save test results
        results = {
            'timestamp': datetime.now().isoformat(),
            'ticker': TICKER,
            'test_metrics': metrics,
            'recent_prediction': recent,
            'model_info': metadata
        }
        
        with open('test_results.json', 'w') as f:
            json.dump(results, f, indent=2)
        
        logger.info("\n✅ Testing selesai! Results disimpan ke test_results.json")
        
        return 0
        
    except Exception as e:
        logger.error(f"❌ Testing gagal: {e}", exc_info=True)
        return 1

if __name__ == "__main__":
    import sys
    sys.exit(main())

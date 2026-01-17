"""
Script untuk prediksi harga GGRM 1-7 hari ke depan
Menggunakan model yang sudah dilatih
"""

import yfinance as yf
import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow.keras.models import load_model
from sklearn.preprocessing import MinMaxScaler
import joblib
import logging
from datetime import datetime, timedelta
import json
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

TICKER = "GGRM.JK"
SEQ_LEN = 60
DAYS_AHEAD = 7
MODEL_PATH = "stock_model.keras"
SCALER_PATH = "scaler_ggrm.pkl"

class GGRMPredictor:
    def __init__(self, model_path=MODEL_PATH, scaler_path=SCALER_PATH):
        """Load model dan scaler"""
        try:
            if not os.path.exists(model_path):
                raise FileNotFoundError(f"Model file not found: {model_path}")
            if not os.path.exists(scaler_path):
                raise FileNotFoundError(f"Scaler file not found: {scaler_path}")
            
            self.model = load_model(model_path)
            self.scaler = joblib.load(scaler_path)
            logger.info("✅ Model dan scaler berhasil dimuat")
        except Exception as e:
            logger.error(f"❌ Error loading model: {e}")
            raise
    
    def get_recent_data(self, ticker=TICKER, days=365):
        """Ambil data recent untuk input sequence"""
        try:
            logger.info(f"Downloading data untuk {ticker}...")
            df = yf.download(ticker, period="1y", interval="1d", progress=False)
            
            if df.empty:
                raise ValueError(f"No data returned for {ticker}")
            
            df = df[['Close']].dropna()
            logger.info(f"✅ Downloaded {len(df)} rows")
            return df
        except Exception as e:
            logger.error(f"Error fetching data: {e}")
            raise
    
    def predict_next_days(self, days=DAYS_AHEAD):
        """Prediksi harga untuk N hari ke depan"""
        try:
            logger.info(f"Prediksi harga GGRM untuk {days} hari ke depan...")
            
            # Get recent data
            df = self.get_recent_data()
            
            # Normalize
            data_scaled = self.scaler.transform(df[['Close']].values)
            
            # Gunakan SEQ_LEN terakhir sebagai input
            current_sequence = data_scaled[-SEQ_LEN:].reshape(1, SEQ_LEN, 1)
            
            predictions = []
            dates = []
            last_date = df.index[-1]
            last_close = float(df['Close'].iloc[-1])
            
            logger.info(f"Last price: {last_close:.2f} on {last_date.strftime('%Y-%m-%d')}")
            
            for day in range(days):
                # Prediksi harga normalisasi
                pred_normalized = self.model.predict(current_sequence, verbose=0)[0][0]
                
                # Denormalisasi
                pred_price = float(self.scaler.inverse_transform([[pred_normalized]])[0][0])
                
                predictions.append(pred_price)
                future_date = (last_date + timedelta(days=day+1)).strftime("%Y-%m-%d")
                dates.append(future_date)
                
                logger.info(f"Day {day+1} ({future_date}): {pred_price:.2f}")
                
                # Update sequence untuk prediksi berikutnya
                current_sequence = np.append(current_sequence[:, 1:, :], 
                                            [[[pred_normalized]]], axis=1)
            
            logger.info("✅ Prediksi selesai")
            return {
                'ticker': TICKER,
                'last_price': round(last_close, 2),
                'last_date': last_date.strftime("%Y-%m-%d"),
                'predictions': [
                    {
                        'date': dates[i],
                        'predicted_price': round(predictions[i], 2),
                        'day_ahead': i + 1,
                        'change_from_last': round(predictions[i] - last_close, 2),
                        'change_percent': round(((predictions[i] - last_close) / last_close) * 100, 2)
                    }
                    for i in range(days)
                ],
                'status': 'success'
            }
            
        except Exception as e:
            logger.error(f"Error predicting: {e}", exc_info=True)
            return {
                'error': str(e),
                'status': 'failed'
            }

def get_prediction_data():
    """Helper function untuk mendapatkan prediksi (untuk API)"""
    try:
        predictor = GGRMPredictor()
        return predictor.predict_next_days(DAYS_AHEAD)
    except Exception as e:
        logger.error(f"Prediction error: {e}")
        return {
            'error': str(e),
            'status': 'failed'
        }

if __name__ == "__main__":
    try:
        predictor = GGRMPredictor()
        result = predictor.predict_next_days(7)
        print("\n" + "="*60)
        print("🎯 STOCK VISION - GGRM PREDIKSI 7 HARI KE DEPAN")
        print("="*60)
        print(json.dumps(result, indent=2))
        print("="*60)
    except Exception as e:
        print(f"❌ Error: {e}")

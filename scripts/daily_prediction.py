"""
Script untuk automated daily predictions & monitoring
Bisa di-run setiap hari untuk track predictions vs actual prices
"""

import numpy as np
import pandas as pd
import tensorflow as tf
import joblib
import yfinance as yf
import json
import logging
from datetime import datetime, timedelta
from pathlib import Path

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

TICKER = "GGRM.JK"
SEQ_LEN = 60
PREDICTIONS_FILE = "ggrm_predictions_history.json"

def load_resources():
    """Load model, scaler, dan predictions history"""
    try:
        model = tf.keras.models.load_model("stock_model.keras", compile=False)
        scaler = joblib.load("scaler_ggrm.pkl")
        
        if Path(PREDICTIONS_FILE).exists():
            with open(PREDICTIONS_FILE, 'r') as f:
                history = json.load(f)
        else:
            history = {"predictions": []}
        
        return model, scaler, history
        
    except Exception as e:
        logger.error(f"Error loading resources: {e}")
        raise

def get_daily_prediction(model, scaler):
    """Get prediction untuk harga GGRM besok"""
    logger.info(f"Getting prediction untuk {TICKER}...")
    
    # Fetch data
    df = yf.download(TICKER, period="3mo", interval="1d", progress=False)
    df = df[['Open', 'High', 'Low', 'Close', 'Volume']].dropna()
    
    # Features
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
    X = np.array([last_seq])
    
    # Predict
    pred_scaled = model.predict(X, verbose=0)[0, 0]
    
    # Inverse transform
    dummy = np.zeros((1, 9))
    dummy[0, 0] = pred_scaled
    predicted_price = scaler.inverse_transform(dummy)[0, 0]
    
    current_price = df['Close'].iloc[-1]
    change = predicted_price - current_price
    change_pct = (change / current_price) * 100
    
    prediction_data = {
        "date": str(datetime.now().date()),
        "prediction_time": datetime.now().isoformat(),
        "current_price": float(current_price),
        "predicted_price": float(predicted_price),
        "change": float(change),
        "change_percent": float(change_pct),
        "direction": "UP" if change > 0 else "DOWN",
        "confidence": "MEDIUM"
    }
    
    return prediction_data

def update_history(new_prediction, history):
    """Update prediction history dengan actual price saat tersedia"""
    predictions = history.get("predictions", [])
    
    # Check if yesterday's prediction exists dan update dengan actual price
    if len(predictions) > 0:
        yesterday_pred = predictions[-1]
        yesterday_date = datetime.fromisoformat(yesterday_pred["date"])
        
        # Fetch actual price yesterday
        actual_date = (datetime.now() - timedelta(days=1)).date()
        
        try:
            df = yf.download(TICKER, start=actual_date, end=actual_date + timedelta(days=1), 
                           progress=False, interval="1d")
            if not df.empty:
                actual_price = df['Close'].iloc[0]
                actual_change = actual_price - yesterday_pred["current_price"]
                actual_change_pct = (actual_change / yesterday_pred["current_price"]) * 100
                actual_direction = "UP" if actual_change > 0 else "DOWN"
                
                # Update prediction dengan actual values
                yesterday_pred["actual_price"] = float(actual_price)
                yesterday_pred["actual_change"] = float(actual_change)
                yesterday_pred["actual_change_percent"] = float(actual_change_pct)
                yesterday_pred["actual_direction"] = actual_direction
                
                # Check accuracy
                predicted_direction = yesterday_pred["direction"]
                accuracy = predicted_direction == actual_direction
                yesterday_pred["direction_accuracy"] = accuracy
                
                predictions[-1] = yesterday_pred
        except Exception as e:
            logger.warning(f"Could not update yesterday's prediction: {e}")
    
    # Add new prediction
    predictions.append(new_prediction)
    
    # Keep only last 90 days
    if len(predictions) > 90:
        predictions = predictions[-90:]
    
    return {"predictions": predictions}

def calculate_accuracy_stats(history):
    """Calculate accuracy statistics"""
    predictions = history.get("predictions", [])
    
    # Filter predictions dengan actual prices
    completed = [p for p in predictions if "actual_price" in p]
    
    if not completed:
        return None
    
    direction_correct = sum([p["direction_accuracy"] for p in completed])
    direction_accuracy = (direction_correct / len(completed)) * 100
    
    # MAPE
    mape_values = []
    for p in completed:
        mape = abs((p["actual_price"] - p["predicted_price"]) / p["actual_price"]) * 100
        mape_values.append(mape)
    
    avg_mape = np.mean(mape_values)
    
    return {
        "total_predictions": len(completed),
        "direction_accuracy": float(direction_accuracy),
        "avg_mape": float(avg_mape),
        "last_updated": datetime.now().isoformat()
    }

def print_report(prediction, stats):
    """Print daily report"""
    print("\n" + "=" * 60)
    print(f"GGRM DAILY PREDICTION REPORT - {prediction['date']}")
    print("=" * 60)
    
    print(f"\n📊 Current Price: Rp {prediction['current_price']:,.0f}")
    print(f"🎯 Predicted Price: Rp {prediction['predicted_price']:,.0f}")
    print(f"📈 Expected Change: Rp {prediction['change']:,.0f} ({prediction['change_percent']:+.2f}%)")
    print(f"🔮 Direction: {prediction['direction']} ↑" if prediction['direction'] == 'UP' else f"🔮 Direction: {prediction['direction']} ↓")
    
    if stats:
        print(f"\n📈 Accuracy Stats (Last 90 days):")
        print(f"   • Direction Accuracy: {stats['direction_accuracy']:.2f}%")
        print(f"   • Avg MAPE: {stats['avg_mape']:.2f}%")
        print(f"   • Total Predictions: {stats['total_predictions']}")
    
    print("\n" + "=" * 60)

def main():
    try:
        logger.info("Starting daily prediction...")
        
        # Load resources
        model, scaler, history = load_resources()
        
        # Get prediction
        prediction = get_daily_prediction(model, scaler)
        
        # Update history
        history = update_history(prediction, history)
        
        # Save history
        with open(PREDICTIONS_FILE, 'w') as f:
            json.dump(history, f, indent=2)
        
        logger.info(f"Prediction saved to {PREDICTIONS_FILE}")
        
        # Calculate stats
        stats = calculate_accuracy_stats(history)
        
        # Print report
        print_report(prediction, stats)
        
        logger.info("✅ Daily prediction completed")
        
        return 0
        
    except Exception as e:
        logger.error(f"❌ Error: {e}", exc_info=True)
        return 1

if __name__ == "__main__":
    import sys
    sys.exit(main())

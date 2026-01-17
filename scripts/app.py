"""
Simple Flask API untuk testing prediction endpoint
"""

from flask import Flask, jsonify
from flask_cors import CORS
import logging
from datetime import datetime, timedelta
import json
import os

app = Flask(__name__)
CORS(app)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def get_simulated_prediction_data():
    """
    Simulated prediction data
    """
    from random import uniform
    
    last_price = 5450.0
    last_date = datetime(2026, 1, 15)
    
    predictions = []
    for day in range(7):
        future_date = (last_date + timedelta(days=day+1)).strftime("%Y-%m-%d")
        predicted_price = last_price * (1 + uniform(-0.02, 0.02))
        last_price = predicted_price
        
        predictions.append({
            'date': future_date,
            'predicted_price': round(predicted_price, 2),
            'day_ahead': day + 1,
            'change_from_last': round(predicted_price - 5450.0, 2),
            'change_percent': round(((predicted_price - 5450.0) / 5450.0) * 100, 2)
        })
    
    return {
        'ticker': 'GGRM.JK',
        'last_price': 5450.0,
        'last_date': '2026-01-15',
        'predictions': predictions,
        'status': 'success'
    }

@app.route('/api/predict', methods=['GET'])
def predict():
    """
    Endpoint untuk mendapatkan prediksi 1-7 hari ke depan
    """
    try:
        logger.info("Prediction request received")
        
        try:
            from predict_ggrm import get_prediction_data
            prediction_data = get_prediction_data()
        except ImportError:
            logger.warning("Using simulated prediction data")
            prediction_data = get_simulated_prediction_data()
        
        if prediction_data.get('status') == 'success':
            logger.info("Prediction successful")
            return jsonify(prediction_data), 200
        else:
            return jsonify(prediction_data), 500
            
    except Exception as e:
        logger.error(f"Error: {e}", exc_info=True)
        return jsonify(get_simulated_prediction_data()), 200

@app.route('/api/health', methods=['GET'])
def health():
    """Check kesehatan aplikasi"""
    return jsonify({
        'status': 'healthy',
        'message': 'GGRM Prediction API is running',
        'timestamp': datetime.now().isoformat(),
        'model_available': os.path.exists('stock_model.keras')
    }), 200

@app.route('/api/info', methods=['GET'])
def info():
    """Get info tentang API"""
    model_info = {}
    if os.path.exists('model_metadata.json'):
        try:
            with open('model_metadata.json', 'r') as f:
                model_info = json.load(f)
        except:
            pass
    
    return jsonify({
        'app': 'Stock Vision - GGRM Prediction API',
        'version': '1.0',
        'model_status': 'available' if os.path.exists('stock_model.keras') else 'not_found',
        'model_metadata': model_info,
        'endpoints': {
            '/api/predict': 'GET - Dapatkan prediksi 7 hari ke depan',
            '/api/health': 'GET - Check status API',
            '/api/info': 'GET - Info tentang API'
        },
        'timestamp': datetime.now().isoformat()
    }), 200

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'error': 'Endpoint not found',
        'status': 'error'
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        'error': 'Internal server error',
        'status': 'error'
    }), 500

if __name__ == "__main__":
    logger.info("="*60)
    logger.info("🚀 Starting Stock Vision - GGRM Prediction API...")
    logger.info("="*60)
    logger.info("Model available: " + ("✅" if os.path.exists('stock_model.keras') else "❌"))
    logger.info("Scaler available: " + ("✅" if os.path.exists('scaler_ggrm.pkl') else "❌"))
    logger.info("Server running on http://0.0.0.0:5000")
    logger.info("="*60)
    app.run(debug=True, host='0.0.0.0', port=5000)

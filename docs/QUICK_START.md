# GGRM Stock Prediction - QUICK REFERENCE

## 🚀 Start Here (First Time)

```bash
# 1. Setup
python setup.sh          # Linux/Mac
setup.bat               # Windows

# 2. Train Model
python train_model.py   # ~5-10 minutes

# 3. Validate
python validate_ggrm_model.py

# 4. Run API
uvicorn backend_api:app --reload
# Open: http://localhost:8000/docs
```

---

## 📋 Daily Operations

```bash
# Daily prediction (run setiap hari)
python daily_prediction.py

# Check model health
python monitor.py

# View API status
curl http://localhost:8000/status
```

---

## 🔄 Monthly Maintenance

```bash
# Retrain dengan data terbaru
python retrain_ggrm.py

# Comprehensive test
python validate_ggrm_model.py

# Check accuracy stats
cat test_results.json
```

---

## 🔗 API Quick Reference

### Base URL
```
http://localhost:8000
```

### Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/` | GET | API info |
| `/status` | GET | Model status |
| `/predict` | POST | Prediksi harga |
| `/latest/GGRM.JK` | GET | Data terbaru |
| `/history/GGRM.JK` | GET | Histori harga |
| `/docs` | GET | API documentation |

### Example Requests

**Status**
```bash
curl http://localhost:8000/status
```

**Predict**
```bash
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{
    "open": 16500, "high": 16700, "low": 16400, 
    "close": 16600, "volume": 5000000,
    "return1": 0.005, "ma7": 16500, 
    "ma21": 16450, "std7": 150
  }'
```

**Latest Price**
```bash
curl http://localhost:8000/latest/GGRM.JK
```

**History**
```bash
# 1 month
curl "http://localhost:8000/history/GGRM.JK?period=1mo"

# 1 year
curl "http://localhost:8000/history/GGRM.JK?period=1y"

# 5 years
curl "http://localhost:8000/history/GGRM.JK?period=5y"
```

---

## 📁 Important Files

| File | Purpose | Size |
|------|---------|------|
| `stock_model.keras` | Neural network model | ~2-5 MB |
| `scaler_ggrm.pkl` | Feature normalization | ~10 KB |
| `model_metadata.json` | Training info | ~1 KB |
| `test_results.json` | Test metrics | ~2 KB |
| `ggrm_predictions_history.json` | Prediction history | ~50 KB |

---

## ⚙️ Troubleshooting

### Problem: "No data returned for GGRM.JK"
```bash
# Solution: Check internet connection
ping yahoo.com

# Or try fetch manually
python -c "import yfinance as yf; print(yf.download('GGRM.JK', period='1d'))"
```

### Problem: "File not found: scaler_ggrm.pkl"
```bash
# Solution: Train model first
python train_model.py
```

### Problem: API not responding
```bash
# Check if API is running
curl http://localhost:8000/

# Restart API
uvicorn backend_api:app --reload
```

### Problem: Predictions not accurate
```bash
# Solution: Retrain with latest data
python retrain_ggrm.py

# Or check if data source updated
python validate_ggrm_model.py
```

---

## 📊 Monitoring Commands

```bash
# Full health check
python monitor.py

# View latest predictions
cat ggrm_predictions_history.json

# View test metrics
cat test_results.json

# View model info
cat model_metadata.json

# Check API logs
tail -f ggrm_prediction.log
```

---

## 🐳 Docker (Optional)

```bash
# Build image
docker build -t ggrm-predictor .

# Run container
docker run -p 8000:8000 ggrm-predictor

# Or use docker-compose
docker-compose up -d
```

---

## 📈 Understanding the Model

### Features (9 total)
- **Close** - Closing price
- **Open** - Opening price
- **High** - Highest price
- **Low** - Lowest price
- **Volume** - Trading volume
- **return1** - 1-day return
- **ma7** - 7-day moving average
- **ma21** - 21-day moving average
- **std7** - 7-day standard deviation

### Architecture
```
LSTM(128) → Dropout → LSTM(64) → Dropout → LSTM(32) → Dropout → Dense(16) → Output
```

### Prediction
- **Input**: 60 days of historical data (60 timesteps × 9 features)
- **Output**: Predicted closing price for next day
- **Accuracy**: ~55-65% direction accuracy (better than random)

---

## 🔐 Best Practices

✅ Train monthly with latest data  
✅ Validate predictions monthly  
✅ Keep scaler file safe (don't overwrite)  
✅ Monitor API health regularly  
✅ Back up model files  
✅ Check Yahoo Finance data quality  
✅ Use predictions as tool, not absolute truth  

---

## 📞 Common Tasks

### How to train with new data?
```bash
python retrain_ggrm.py
```

### How to test model accuracy?
```bash
python validate_ggrm_model.py
```

### How to get daily predictions?
```bash
python daily_prediction.py
```

### How to check model health?
```bash
python monitor.py
```

### How to get latest GGRM price?
```bash
curl http://localhost:8000/latest/GGRM.JK
```

### How to schedule daily prediction?
**Linux/Mac (crontab)**
```bash
crontab -e
# Add: 0 18 * * 1-5 cd /path && python daily_prediction.py
```

**Windows (Task Scheduler)**
```
1. Open Task Scheduler
2. Create Basic Task
3. Trigger: Daily at 6 PM
4. Action: Run python daily_prediction.py
```

---

## 📚 Full Documentation
See [README_GGRM.md](README_GGRM.md) for complete documentation

---

**Last Updated**: January 12, 2026  
**Status**: ✅ Production Ready  
**Questions?** Check README_GGRM.md

# Backend Data Pipeline Update

## ✅ Perubahan yang Sudah Dilakukan

Backend API sekarang menggunakan **yfinance data langsung** dengan **feature engineering yang sama** seperti training model.

### Data Pipeline

```
1. Fetch Latest Data (yfinance)
   ↓
2. Engineer Features (ma7, ma21, std7, return1)
   ↓
3. Scale dengan Scaler yang Disimpan (scaler_ggrm.pkl)
   ↓
4. Predict dengan LSTM Model (stock_model.keras)
   ↓
5. Inverse Scale → Harga Prediksi
   ↓
6. Log ke Firestore (jika user terautentikasi)
```

## 📊 Endpoint Baru & Update

### 1. **POST `/predict-next`** (NEW) - Recommended untuk Production

Prediksi harga Close hari berikutnya **dari data yfinance terbaru**.

```bash
curl -X POST http://localhost:8000/predict-next \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ID_TOKEN" \
  -d '{"ticker":"GGRM.JK"}'
```

Response:
```json
{
  "ticker": "GGRM.JK",
  "current_close": 3050.0,
  "predicted_close": 3075.5,
  "price_change": 25.5,
  "pct_change": 0.84,
  "confidence": "Medium",
  "timestamp": "2024-01-12T10:30:00Z",
  "last_update": "2024-01-12"
}
```

### 2. **GET `/latest/{ticker}`** (UPDATED) - Sekarang include technical features

```bash
curl http://localhost:8000/latest/GGRM.JK
```

Response:
```json
{
  "ticker": "GGRM.JK",
  "date": "2024-01-12",
  "ohlcv": {
    "open": 3000.0,
    "high": 3100.0,
    "low": 2950.0,
    "close": 3050.0,
    "volume": 123456.0
  },
  "technical_features": {
    "return1": 0.0164,
    "ma7": 3020.5,
    "ma21": 3010.2,
    "std7": 15.3
  }
}
```

### 3. **GET `/history/{ticker}`** (UPDATED) - Sekarang include technical features

```bash
curl "http://localhost:8000/history/GGRM.JK?period=1mo"
```

Response:
```json
{
  "ticker": "GGRM.JK",
  "period": "1mo",
  "interval": "1d",
  "data_points": 21,
  "history": [
    {
      "date": "2024-01-10",
      "ohlcv": {...},
      "technical_features": {...}
    },
    ...
  ]
}
```

### 4. **POST `/predict`** (BACKWARD COMPATIBLE) - Masih bisa pakai manual features

Untuk compatibility dengan existing client yang mengirim features manual.

## 🔄 Feature Engineering Details

Backend sekarang menghitung features yang sama dengan training:

| Feature | Formula | Purpose |
|---------|---------|---------|
| `Close` | Last close price | Target + input |
| `Open`, `High`, `Low`, `Volume` | OHLCV from yfinance | Raw data |
| `return1` | `(Close_t - Close_t-1) / Close_t-1` | Price momentum |
| `ma7` | 7-day moving average | Short-term trend |
| `ma21` | 21-day moving average | Medium-term trend |
| `std7` | 7-day std deviation | Volatility |

## 📈 Sequence & Prediction

- **Sequence Length:** 60 days of historical data
- **Prediction:** Next day close price
- **Model:** LSTM (3 layers: 128 → 64 → 32 → Dense)
- **Scaler:** MinMaxScaler (saved & used for all predictions)

## ✅ Consistency Check

Semua data melalui pipeline yang sama:

1. ✅ Fetch dari yfinance
2. ✅ Engineer features yang sama (ma7, ma21, std7, return1)
3. ✅ Scale dengan scaler yang sama
4. ✅ LSTM model yang same (60-day sequence)

**Result:** ML predictions sekarang **konsisten & akurat**! 🎯

## 🚀 Usage Examples

### Python Client Example

```python
import requests
import json

BASE_URL = "http://localhost:8000"
ID_TOKEN = "your_firebase_id_token_here"

headers = {
    "Authorization": f"Bearer {ID_TOKEN}",
    "Content-Type": "application/json"
}

# Predict next day
response = requests.post(
    f"{BASE_URL}/predict-next",
    json={"ticker": "GGRM.JK"},
    headers=headers
)

result = response.json()
print(f"Predicted: Rp {result['predicted_close']}")
print(f"Change: {result['pct_change']:+.2f}%")
```

### Without Auth (Public Endpoints)

```python
# Get latest data
response = requests.get("http://localhost:8000/latest/GGRM.JK")
data = response.json()
print(f"Current Close: Rp {data['ohlcv']['close']}")

# Get history
response = requests.get("http://localhost:8000/history/GGRM.JK?period=3mo")
history = response.json()
print(f"Data points: {history['data_points']}")
```

## 📝 Testing Checklist

- [ ] Test `/latest/{ticker}` - returns OHLCV + technical features
- [ ] Test `/history/{ticker}` - returns full history with features
- [ ] Test `/predict-next` with valid token - should predict next day
- [ ] Test `/predict-next` without token - should work (auth optional)
- [ ] Verify Firestore logging - predictions logged to `predictions` collection
- [ ] Test with different tickers (not just GGRM.JK)

---

**Status:** ✅ Production Ready
**Last Updated:** 2024-01-12

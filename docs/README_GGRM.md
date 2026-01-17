# GGRM Stock Prediction Model - Dokumentasi

## 📋 Overview
Model ini adalah LSTM-based stock price prediction untuk saham GGRM (Gudang Garam) yang menggunakan data real-time dari Yahoo Finance.

---

## 🏗️ Arsitektur Model

### Data Source
- **Yahoo Finance** melalui library `yfinance`
- **Ticker**: GGRM.JK (Gudang Garam, Bursa Efek Indonesia)
- **Historical Data**: 5 tahun terakhir
- **Update**: Real-time dari Yahoo Finance

### Features yang Digunakan
1. **Close** - Harga penutupan
2. **Open** - Harga pembukaan
3. **High** - Harga tertinggi
4. **Low** - Harga terendah
5. **Volume** - Volume perdagangan
6. **return1** - Return 1 hari
7. **ma7** - Moving Average 7 hari
8. **ma21** - Moving Average 21 hari
9. **std7** - Standard Deviation 7 hari

### Model Architecture (LSTM)
```
Input Layer (60 timesteps x 9 features)
    ↓
LSTM Layer 1 (128 units, return_sequences=True)
    ↓
Dropout (0.2)
    ↓
LSTM Layer 2 (64 units, return_sequences=True)
    ↓
Dropout (0.2)
    ↓
LSTM Layer 3 (32 units)
    ↓
Dropout (0.2)
    ↓
Dense Layer (16 units, ReLU)
    ↓
Output Layer (1 unit - predicted price)
```

---

## 📁 File Structure

```
.
├── train_model.py              # Training script untuk GGRM
├── retrain_ggrm.py            # Retrain otomatis dengan data terbaru
├── validate_ggrm_model.py      # Testing & validation
├── backend_api.py              # FastAPI endpoints
├── stock_model.keras           # Trained model (output)
├── scaler_ggrm.pkl            # MinMaxScaler (output)
├── model_metadata.json         # Model metadata (output)
└── requirements.txt            # Dependencies
```

---

## 🚀 Cara Menggunakan

### 1. Setup Environment
```bash
# Install dependencies
pip install -r requirements.txt

# Atau dengan conda
conda create -n ggrm-predictor python=3.9
conda activate ggrm-predictor
pip install -r requirements.txt
```

### 2. Training Model GGRM
```bash
# Train model baru dengan 5 tahun data GGRM
python train_model.py

# Output:
# - stock_model.keras (model)
# - scaler_ggrm.pkl (feature scaler)
# - model_metadata.json (training info)
```

### 3. Validasi Model
```bash
# Test model dengan 6 bulan data terakhir
python validate_ggrm_model.py

# Output:
# - test_results.json (metrics & predictions)
# - Console output dengan MAPE, R², dll
```

### 4. Retrain Berkala
```bash
# Update model dengan data terbaru
python retrain_ggrm.py

# Bisa dijadwalkan dengan cron (Linux) atau Task Scheduler (Windows)
# Contoh cron: 0 18 * * 1-5 cd /path/to/project && python retrain_ggrm.py
```

### 5. Jalankan API
```bash
# Development
uvicorn backend_api:app --reload

# Production
gunicorn -w 4 -k uvicorn.workers.UvicornWorker backend_api:app
```

---

## 📊 API Endpoints

### GET /
Status API
```bash
curl http://localhost:8000/
```

### GET /status
Informasi model & metadata
```bash
curl http://localhost:8000/status
```

### POST /predict
Prediksi harga GGRM
```bash
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{
    "open": 16500.0,
    "high": 16700.0,
    "low": 16400.0,
    "close": 16600.0,
    "volume": 5000000.0,
    "return1": 0.005,
    "ma7": 16500.0,
    "ma21": 16450.0,
    "std7": 150.0
  }'
```

### GET /latest/{ticker}
Data GGRM terbaru
```bash
curl http://localhost:8000/latest/GGRM.JK
```

### GET /history/{ticker}
Histori harga GGRM
```bash
curl "http://localhost:8000/history/GGRM.JK?period=1mo&interval=1d"

# Parameters:
# - period: 1d, 5d, 1mo, 3mo, 6mo, 1y, 2y, 5y, 10y, ytd, max
# - interval: 1m, 5m, 15m, 30m, 60m, 1d, 1wk, 1mo
```

---

## 🔄 Workflow Lengkap

### Initial Setup
```
1. pip install -r requirements.txt
2. python train_model.py              # Generate model pertama kali
3. python validate_ggrm_model.py      # Validasi model
```

### Production
```
1. python backend_api.py              # Jalankan API
2. (Scheduled) python retrain_ggrm.py # Update bulanan/mingguan
3. (Daily) python validate_ggrm_model.py # Monitor performance
```

---

## 📈 Training Details

| Parameter | Value |
|-----------|-------|
| **Ticker** | GGRM.JK |
| **Data Period** | 5 years |
| **Sequence Length** | 60 days |
| **Prediction Horizon** | 1 day |
| **Train/Test Split** | 80/20 |
| **Epochs** | 50 |
| **Batch Size** | 32 |
| **Optimizer** | Adam |
| **Loss Function** | MSE |
| **Scaling Method** | MinMaxScaler |

---

## 📊 Output Files Dijelaskan

### stock_model.keras
- Format: Keras H5 format
- Size: ~2-5 MB
- Berisi: Neural network weights & architecture
- Update: Setelah `train_model.py` atau `retrain_ggrm.py`

### scaler_ggrm.pkl
- Format: Pickle binary
- Size: ~10 KB
- Fungsi: Normalisasi features saat inference
- **IMPORTANT**: Harus sama dengan scaler training!

### model_metadata.json
- Format: JSON
- Isi: Training date, data rows, metrics, etc.
- Update: Setelah training

### test_results.json
- Format: JSON
- Isi: Test metrics, recent predictions
- Update: Setelah `validate_ggrm_model.py`

---

## ⚠️ Important Notes

1. **Scaler Consistency**: Scaler yang digunakan saat training HARUS sama dengan saat inference
2. **Data Freshness**: Untuk hasil terbaik, retrain minimal sebulan sekali
3. **Yahoo Finance Limits**: Jangan fetch data terlalu sering (>2-3 kali per menit)
4. **Model Retraining**: Retraining membutuhkan waktu 10-15 menit tergantung CPU
5. **Feature Order**: Order 9 features HARUS selalu sama: `[Close, Open, High, Low, Volume, return1, ma7, ma21, std7]`

---

## 🔧 Troubleshooting

### Error: "No data returned for GGRM.JK"
- Cek koneksi internet
- Yahoo Finance mungkin down (cek https://finance.yahoo.com)
- Tunggu beberapa menit dan coba lagi

### Error: "File not found: scaler_ggrm.pkl"
- Jalankan `train_model.py` terlebih dahulu
- Scaler harus digenerate saat training

### Prediksi tidak akurat
- Data outdated → Jalankan `retrain_ggrm.py`
- Features input salah → Cek urutan 9 features
- Market conditions berubah drastis → Wajar, LSTM ada limitations

### API slow
- Model besar, inference butuh 1-2 detik
- Deploy ke GPU untuk lebih cepat
- Gunakan model quantization untuk inference lebih fast

---

## 📚 References

- [Yahoo Finance API](https://finance.yahoo.com)
- [TensorFlow LSTM](https://www.tensorflow.org/api_docs/python/tf/keras/layers/LSTM)
- [Scikit-learn Preprocessing](https://scikit-learn.org/stable/modules/preprocessing.html)
- [FastAPI](https://fastapi.tiangolo.com/)

---

## 📝 Maintenance Checklist

- [ ] Retrain model sebulan sekali
- [ ] Check test_results.json untuk MAPE < 5%
- [ ] Monitor API response time
- [ ] Update dependencies setiap quarter
- [ ] Backup model files secara berkala
- [ ] Check Yahoo Finance data quality

---

**Last Updated**: January 2026  
**Model Type**: LSTM (3 layers)  
**Target**: GGRM.JK Stock Price Prediction  
**Data Source**: Yahoo Finance (Real-time)

# TODO: Scrape Data GGRM & Retrain Model

## Status: IN PROGRESS
## Tanggal: -

### Langkah-langkah:

- [ ] 1. Fetch data GGRM terbaru dari yfinance (5 tahun)
- [ ] 2. Prepare sequences dengan feature engineering
- [ ] 3. Train LSTM model dengan data baru
- [ ] 4. Save model baru (stock_model.keras)
- [ ] 5. Save scaler baru (scaler_ggrm.pkl)
- [ ] 6. Update model metadata (model_metadata.json)
- [ ] 7. Verifikasi model baru berfungsi

### Catatan:
- Menggunakan script `retrain_ggrm.py` yang sudah ada
- Ticker: GGRM.JK
- Sequence length: 60 hari
- Features: Close, Open, High, Low, Volume, return1, ma7, ma21, std7


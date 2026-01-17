# Firebase Integration Guide

Panduan lengkap untuk menghubungkan backend FastAPI dengan Firebase Admin SDK, Firestore, dan FCM.

## Prerequisites

- Firebase project sudah dibuat di Firebase Console
- Service Account JSON sudah di-generate dari Firebase Console → Project Settings → Service accounts
- `firebase-admin` package sudah terinstall

## 1. Setup Environment Variable

### Opsi A: Environment Variable (lokal/server)

Simpan Service Account JSON di server (jangan commit ke git), lalu set environment variable:

```bash
# Linux / Mac
export FIREBASE_CREDENTIALS=/full/path/to/Secret/stock-prediction-realtime-firebase-adminsdk-fbsvc-6d0f85bf5b.json

# atau gunakan GOOGLE_APPLICATION_CREDENTIALS
export GOOGLE_APPLICATION_CREDENTIALS=/full/path/to/service-account.json
```

### Opsi B: Docker / docker-compose

Gunakan bind mount dan environment variable:

```yaml
version: '3.8'
services:
  api:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - /full/path/to/service-account.json:/run/secrets/firebase-service-account.json:ro
    environment:
      - FIREBASE_CREDENTIALS=/run/secrets/firebase-service-account.json
    command: uvicorn backend_api:app --host 0.0.0.0 --port 8000
```

### Opsi C: Cloud Platform (Vercel, Render, Google Cloud Run)

Upload service account JSON ke secret manager dan set environment variable dalam deployment config.

## 2. Install Dependencies

```bash
pip install -r requirements.txt
```

## 3. Start Backend API

```bash
# dengan hot reload (dev)
uvicorn backend_api:app --reload --host 0.0.0.0 --port 8000

# production
uvicorn backend_api:app --host 0.0.0.0 --port 8000 --workers 4
```

Server akan log:
```
Firebase Admin berhasil diinisialisasi
```

Akses API docs: `http://localhost:8000/docs`

## 4. Firebase Collections Schema

Backend otomatis membuat data berikut di Firestore:

### Collection: `predictions`

Setiap prediksi dari user terautentikasi disimpan:

```json
{
  "uid": "user123",
  "email": "user@example.com",
  "ticker": "GGRM.JK",
  "input": [3000, 3100, 2950, 3050, 123456, 0.01, 3020, 2980, 15],
  "predicted_close": 3075.5,
  "timestamp": "2024-01-12T10:30:00Z"
}
```

### Collection: `users`

User profile (opsional, via POST /profile):

```json
{
  "uid": "user123",
  "email": "user@example.com",
  "displayName": "John Doe",
  "createdAt": "2024-01-12T10:00:00Z",
  "totalPredictions": 5
}
```

## 5. API Endpoints

### Public Endpoints (tanpa autentikasi)

```bash
# Status API
GET /status

# Fetch latest stock data
GET /latest/GGRM.JK

# Fetch history
GET /history/GGRM.JK?period=1mo&interval=1d
```

### Protected Endpoints (memerlukan Firebase ID Token)

Sertakan header:
```
Authorization: Bearer <ID_TOKEN>
```

#### 5.1 POST /predict - Prediksi harga

```bash
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ID_TOKEN" \
  -d '{
    "open": 3000,
    "high": 3100,
    "low": 2950,
    "close": 3050,
    "volume": 123456,
    "return1": 0.01,
    "ma7": 3020,
    "ma21": 2980,
    "std7": 15
  }'
```

Response:
```json
{
  "predicted_close": 3075.5,
  "confidence": "Medium",
  "timestamp": "2024-01-12T10:30:00Z"
}
```

Prediksi otomatis disimpan ke koleksi `predictions` di Firestore.

#### 5.2 POST /profile - Buat/update profil user

```bash
curl -X POST http://localhost:8000/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ID_TOKEN" \
  -d '{
    "displayName": "John Doe",
    "phoneNumber": "+62812345678"
  }'
```

Response:
```json
{
  "uid": "user123",
  "email": "user@example.com",
  "displayName": "John Doe",
  "phoneNumber": "+62812345678",
  "updatedAt": "2024-01-12T10:30:00Z"
}
```

#### 5.3 GET /profile - Ambil profil user

```bash
curl -X GET http://localhost:8000/profile \
  -H "Authorization: Bearer YOUR_ID_TOKEN"
```

Response:
```json
{
  "uid": "user123",
  "email": "user@example.com",
  "displayName": "John Doe",
  "phoneNumber": "+62812345678",
  "createdAt": "2024-01-12T10:00:00Z",
  "updatedAt": "2024-01-12T10:30:00Z"
}
```

#### 5.4 POST /notify - Kirim FCM notification (admin)

```bash
curl -X POST http://localhost:8000/notify \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ID_TOKEN" \
  -d '{
    "title": "Prediksi GGRM Terbaru",
    "body": "Harga GGRM diprediksi naik menjadi 3075.5",
    "predictedClose": 3075.5,
    "ticker": "GGRM.JK"
  }'
```

Response:
```json
{
  "success": true,
  "message": "Notifikasi berhasil dikirim",
  "sentTo": 5
}
```

## 6. Mobile Client Integration

### 6.1 React Native / Flutter (Firebase SDK)

```javascript
// Sign in user
const userCredential = await firebase.auth().signInWithEmail(email, password);
const idToken = await userCredential.user.getIdToken();

// Call protected endpoint
const response = await fetch('http://your-backend.com/predict', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${idToken}`
  },
  body: JSON.stringify({...})
});
```

### 6.2 Subscribe ke notifikasi FCM (Flutter)

```dart
final messaging = FirebaseMessaging.instance;
final token = await messaging.getToken();

// Kirim token ke backend (via /profile endpoint)
await http.post(
  Uri.parse('http://your-backend.com/profile'),
  headers: {'Authorization': 'Bearer $idToken'},
  body: jsonEncode({'fcmToken': token})
);
```

## 7. Firestore Security Rules

Salin rules berikut ke Firebase Console → Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Predictions - user hanya bisa baca milik mereka sendiri
    match /predictions/{docId} {
      allow create: if request.auth != null && request.resource.data.uid == request.auth.uid;
      allow read: if request.auth != null && request.auth.uid == resource.data.uid;
      allow list: if request.auth != null && resource.data.uid == request.auth.uid;
    }

    // Users - user hanya bisa baca/tulis milik mereka sendiri
    match /users/{userId} {
      allow create: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 8. Troubleshooting

### Firebase tidak terload

```
Tidak ada kredensial Firebase (env FIREBASE_CREDENTIALS tidak diset). Firebase dinonaktifkan.
```

**Solusi:** Set environment variable `FIREBASE_CREDENTIALS` atau `GOOGLE_APPLICATION_CREDENTIALS`.

### Token verification gagal

```
Verifikasi token gagal: ...
```

**Solusi:** Pastikan token valid dan belum expired. Request ID token baru dari mobile client.

### Firestore permission denied

```
Permission denied: missing or insufficient permissions
```

**Solusi:** Update Firestore security rules seperti contoh di atas.

## 9. Testing dengan Postman

1. Import ke Postman:
   - **Auth Type:** Bearer Token
   - **Token:** (paste ID token dari Firebase client)

2. Set pre-request script (auto-refresh token):
```javascript
// Implementasi di mobile client - dapatkan token baru
pm.environment.set("id_token", "YOUR_FRESH_TOKEN");
```

## 10. Production Checklist

- [ ] Service account JSON disimpan di secret manager (bukan di repo)
- [ ] Environment variable `FIREBASE_CREDENTIALS` di-set di server/container
- [ ] Firestore security rules sudah di-publish
- [ ] Backend API running di HTTPS (gunakan reverse proxy: nginx, Cloudflare, dll.)
- [ ] CORS di-config sesuai domain mobile app
- [ ] Rate limiting di-aktifkan untuk endpoint `/predict`
- [ ] Monitoring/logging di-setup (Google Cloud Logging, atau ELK)

## 11. Dokumentasi Lanjutan

- Firebase Admin SDK: https://firebase.google.com/docs/admin/setup
- Firestore: https://firebase.google.com/docs/firestore
- FCM: https://firebase.google.com/docs/cloud-messaging
- FastAPI Security: https://fastapi.tiangolo.com/tutorial/security/

---

**Last Updated:** 2024-01-12

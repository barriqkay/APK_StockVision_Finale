# Flutter Project Migration Plan

## Tujuan
Memperbaiki struktur project Flutter yang tidak lengkap (missing android/, ios/, web/ folders)

## Status: ✅ COMPLETED

## Steps

### Step 1: Backup File yang Ada
- [x] Backup folder `lib/`
- [x] Backup file `pubspec.yaml`
- [x] Backup folder `mobile_app/assets/`

### Step 2: Buat Flutter Project Baru
- [x] Jalankan `flutter create -t app ggrm_stock_app`

### Step 3: Pindahkan File
- [x] Pindahkan `lib/` ke project baru
- [x] Pindahkan `pubspec.yaml` ke project baru
- [x] Pindahkan assets dari `mobile_app/assets/` ke project baru

### Step 4: Update Konfigurasi
- [x] Update `pubspec.yaml` assets path
- [x] Verifikasi struktur project baru

### Step 5: Testing
- [x] Jalankan `flutter pub get`
- [ ] Jalankan `flutter run` untuk test (opsional)

## Hasil Project Baru

**Lokasi:** `/home/berkuiii/Documents/stock-predict-backend-main/ggrm_stock_app/`

**Struktur:**
```
ggrm_stock_app/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   └── predict_screen.dart
│   ├── services/
│   │   └── api_service.dart
│   └── widgets/
│       ├── custom_button.dart
│       └── input_field.dart
├── assets/
├── android/ ✅
├── ios/ ✅
├── web/ ✅
├── linux/ ✅
├── macos/ ✅
└── windows/ ✅
```

## Backup yang Tersimpan
- `lib_backup/` - Backup folder lib lama
- `pubspec_backup.yaml` - Backup pubspec lama
- `assets_backup/` - Backup assets lama

## Cara Menjalankan Project Baru
```bash
cd /home/berkuiii/Documents/stock-predict-backend-main/ggrm_stock_app
/home/berkuiii/flutter/bin/flutter run
```

## Menambahkan Path Flutter Permanen (Opsional)
Tambahkan ke `~/.bashrc` atau `~/.zshrc`:
```bash
export PATH="$PATH:/home/berkuiii/flutter/bin"
```


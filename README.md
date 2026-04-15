# PLN App - Installation & Initialization Guide

PLN App adalah aplikasi mobile untuk manajemen data pelanggan PLN dengan backend Laravel API.

## 📋 Daftar Isi
- [Prasyarat](#prasyarat)
- [Struktur Proyek](#struktur-proyek)
- [Instalasi Backend (Laravel)](#instalasi-backend-laravel)
- [Instalasi Frontend (Flutter)](#instalasi-frontend-flutter)
- [Menjalankan Aplikasi](#menjalankan-aplikasi)
- [Konfigurasi API](#konfigurasi-api)
- [Troubleshooting](#troubleshooting)

---

## 🔧 Prasyarat

### Untuk Backend (Laravel)
- **PHP** (versi 8.3 atau lebih tinggi)
  ```
  php --version
  ```
- **Composer** (PHP Package Manager)
  ```
  composer --version
  ```
- **Database** (MySQL/PostgreSQL)

### Untuk Frontend (Flutter)
- **Flutter SDK** (versi 3.11.4 atau lebih tinggi)
  ```
  flutter --version
  ```
- **Dart SDK** (included dengan Flutter)
- **Android Studio** atau **Visual Studio Code**
- Untuk Android: Android SDK level 21 atau lebih tinggi
- Untuk iOS: Xcode (di macOS)

---

## 📁 Struktur Proyek

```
joki flutter/
├── pln_app/              # Frontend - Flutter App
│   ├── lib/              # Source code
│   ├── assets/           # Images, SVG, etc
│   ├── android/          # Android native code
│   ├── ios/              # iOS native code
│   └── pubspec.yaml      # Flutter dependencies
└── pln-backend/          # Backend - Laravel API
    ├── app/              # Application logic
    ├── database/         # Migrations & seeders
    ├── routes/           # API routes
    ├── config/           # Configuration files
    └── composer.json     # Laravel dependencies
```

---

## 🚀 Instalasi Backend (Laravel)

### 1. Navigasi ke Folder Backend
```bash
cd pln-backend
```

### 2. Install Dependencies
```bash
composer install
```

### 3. Setup Environment File
```bash
# Copy .env.example ke .env
cp .env.example .env
```

### 4. Generate Application Key
```bash
php artisan key:generate
```

### 5. Setup Database
Perbarui konfigurasi database di file `.env`:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=pln_app
DB_USERNAME=root
DB_PASSWORD=
```

### 6. Run Database Migrations
```bash
php artisan migrate
```

### 7. Install Frontend Assets
```bash
npm install
npm run build
```

### 8. Buat Database Seeder (Opsional)
```bash
php artisan db:seed
```

---

## 📱 Instalasi Frontend (Flutter)

### 1. Navigasi ke Folder Frontend
```bash
cd pln_app
```

### 2. Get Flutter Dependencies
```bash
flutter pub get
```

### 3. Verifikasi Setup
Untuk memastikan semua setup sudah benar:

#### Android:
```bash
flutter doctor -v
```
Pastikan Android SDK dan Gradle sudah terinstall dengan baik.

#### iOS (macOS only):
```bash
cd ios
pod install
cd ..
```

---

## ▶️ Menjalankan Aplikasi

### 1. Jalankan Backend Laravel
Dari folder `pln-backend`:
```bash
php artisan serve
```
Backend akan berjalan di: `http://127.0.0.1:8000`

### 2. Jalankan Frontend Flutter
Dari folder `pln_app`:

#### Untuk Android Emulator/Device:
```bash
flutter run -d android
```

#### Untuk iOS Simulator (macOS):
```bash
flutter run -d ios
```

#### Untuk Web (Preview):
```bash
flutter run -d web
```

---

## ⚙️ Konfigurasi API

### Backend API Base URL
Edit file `lib/api_service.dart` dan perbarui `API_BASE_URL`:

```dart
class ApiService {
  static const String API_BASE_URL = 'http://10.0.2.2:8000/api';
  // Gunakan:
  // - http://10.0.2.2:8000/api (Android Emulator)
  // - http://localhost:8000/api (iOS Simulator / Web)
  // - http://<IP_ADDRESS>:8000/api (Physical Device)
}
```

### Available Dependencies
Frontend Flutter menggunakan:
- **sqflite** - Local database
- **http** - HTTP client untuk API calls
- **image_picker** - Galeri/kamera
- **camera** - Akses kamera
- **geolocator** - Lokasi GPS
- **connectivity_plus** - Cek koneksi internet
- **shared_preferences** - Local storage key-value
- **path_provider** - File system paths
- **flutter_svg** - SVG rendering

---

## 📝 Catatan Penting

### API Endpoints yang Tersedia:
- `POST /api/register` - Registrasi pengguna (sedang dalam pengembangan)
- `POST /api/login` - Login pengguna (sedang dalam pengembangan)
- `POST /api/sync-pelanggan` - Sinkronisasi data pelanggan
- `POST /api/upload-foto` - Upload foto profil

### Database Locals (SQLite):
Frontend menggunakan SQLite untuk penyimpanan lokal:
- User credentials
- Customer data
- Cached information

### Koneksi Internet:
Aplikasi mengecek koneksi internet sebelum melakukan API calls menggunakan `connectivity_plus`.

---

## 🐛 Troubleshooting

### Flutter: "Command not found: flutter"
```bash
# Tambahkan Flutter ke PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

### Laravel: "SQLSTATE[HY000] [2002] Connection refused"
- Pastikan database server sudah berjalan
- Verifikasi konfigurasi `.env` sudah benar

### API Connection Timeout
- Verifikasi `API_BASE_URL` di `lib/api_service.dart` sudah benar
- Untuk Android Emulator, gunakan IP `10.0.2.2` bukan `localhost`
- Untuk device fisik, gunakan IP lokal (contoh: `192.168.x.x`)

### Flutter Hot Reload Error
```bash
flutter clean
flutter pub get
flutter run
```

### Permission Issues (Android)
Pastikan permissions sudah di-request di `AndroidManifest.xml`:
- INTERNET
- ACCESS_FINE_LOCATION
- READ_EXTERNAL_STORAGE
- WRITE_EXTERNAL_STORAGE
- CAMERA

---

## 📞 Support

Jika ada pertanyaan atau masalah dalam setup, silakan periksa:
1. Dokumentasi Flutter: https://flutter.dev/docs
2. Dokumentasi Laravel: https://laravel.com/docs
3. File repository memory untuk catatan teknis project

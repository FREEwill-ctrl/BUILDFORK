
# Todo Modular Flutter App

A modern, modular Todo & Pomodoro app built with Flutter. Mendukung prioritas Eisenhower, deadline dengan jam, mode malam/siang, upload file, dan build otomatis APK via GitHub Actions.

## Fitur Utama
- **Todo List** dengan prioritas Eisenhower (Penting & Mendesak, dst)
- **Checklist**, deadline (tanggal & jam), dan upload lampiran file
- **Edit, hapus, filter, dan tandai selesai** todo
- **Kalender** untuk filter todo per tanggal
- **Pomodoro Timer**: 25/5/15 menit, statistik, suara alarm, pengaturan durasi
- **Statistik todo & pomodoro**
- **Mode malam/siang** (toggle di semua halaman)
- **Offline** (data lokal, tidak perlu login)
- **Build APK otomatis** (CI/CD GitHub Actions)

## Struktur Project
```
├── .github/workflows/         # CI/CD build & analyze APK
├── android/                   # Android config
├── assets/                    # Ikon & suara
├── lib/
│   ├── features/
│   │   ├── todo/              # Todo list, kalender, filter, edit
│   │   ├── pomodoro/          # Pomodoro timer & statistik
│   │   └── stats/             # Statistik
│   └── shared/                # Theme, constants, provider
│   └── main.dart              # Entry point
├── pubspec.yaml               # Dependencies
└── README.md
```

## Cara Menjalankan
1. **Clone repo & install dependencies**
   ```bash
   git clone <repo-url>
   cd <repo-folder>
   flutter pub get
   ```
2. **Jalankan aplikasi**
   ```bash
   flutter run
   ```
3. **Build APK release**
   ```bash
   flutter build apk --release
   ```
   APK ada di `build/app/outputs/flutter-apk/app-release.apk`

## CI/CD: Build Otomatis APK
- Setiap push ke `main` akan otomatis:
  - `flutter analyze` (cek code style)
  - Build APK release
  - Upload APK ke GitHub Actions artifact
- Workflow: `.github/workflows/build_android.yml`

## Fitur Lain
- **Mode malam/siang**: toggle di AppBar semua halaman
- **Upload file**: lampirkan file ke todo (offline, hanya path lokal)
- **Deadline dengan jam**: pilih tanggal & jam untuk tenggat todo
- **Prioritas Eisenhower**: filter & label warna
- **Statistik**: todo & pomodoro
- **UI/UX modern**: Material 3, animasi smooth, responsif

## Kontribusi
Pull request & issue sangat diterima! Pastikan kode sudah lolos `flutter analyze` dan build APK sebelum mengirim PR.

---

**Project ini open source & siap dikembangkan lebih lanjut!**


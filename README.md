
# Todo Modular Flutter App

A modern, modular Todo & Pomodoro app built with Flutter.

## Struktur Proyek (Sederhana)
```
├── lib/
│   ├── features/      # Fitur utama: todo, pomodoro, statistik
│   ├── shared/        # Theme, provider, utilitas
│   └── main.dart      # Entry point aplikasi
├── assets/            # Ikon & suara
├── android/           # Konfigurasi Android
├── .github/workflows/ # CI/CD build APK
├── pubspec.yaml       # Dependency
```

## Fitur Utama
- Todo List dengan prioritas Eisenhower (Penting & Mendesak, dst)
- Checklist, deadline (tanggal & jam), upload file
- Edit, hapus, filter, tandai selesai
- Kalender filter todo
- Pomodoro Timer (25/5/15 menit, statistik, alarm, pengaturan)
- Statistik todo & pomodoro
- Mode malam/siang (toggle di AppBar)
- Offline (data lokal)
- Build APK otomatis (GitHub Actions)

## Cara Menjalankan
1. **Install dependency:**
   ```bash
   flutter pub get
   ```
2. **Jalankan aplikasi:**
   ```bash
   flutter run
   ```
3. **Build APK release:**
   ```bash
   flutter build apk --release
   ```
   APK ada di `build/app/outputs/flutter-apk/app-release.apk`

## CI/CD (Singkat)
- Setiap push ke `main`:
  - Jalankan `flutter analyze` & build APK release
  - APK otomatis di-upload ke GitHub Actions artifact

---

**Project open source, siap dikembangkan lebih lanjut!**


# 💰 HealthFlow - Complete Flutter Version

Smart Money Management App dengan semua fitur lengkap.

## 🎯 Fitur Lengkap

✅ **Dashboard** - 3 Jar otomatis, balance tracking
✅ **Record Income/Expense** - Pencatatan otomatis dengan kategori
✅ **Mode Personal** - Split 17-10-10 (Saving-Growth-Zakat)
✅ **Mode Bisnis** - 3 metode pembagian profit (Balanced/Cashflow/Berkah)
✅ **Flexing Detector** - Analisa NEED/WANT/FLEXING dengan offline AI
✅ **Savings Calculator** - Reverse goal calculator untuk target tabungan
✅ **Zakat Calculator** - Tracking zakat maal dengan nisab check
✅ **Habits Tracker** - Daily habit checklist
✅ **Dark & Light Theme** - Toggle tema
✅ **Bilingual** - ID & EN support
✅ **Local Storage** - Semua data tersimpan offline

## 🚀 Setup (5 menit)

### Prerequisites
```bash
# Install Flutter dari https://flutter.dev/docs/get-started/install
# Verify:
flutter doctor
# Pastikan semua ✅
```

### Run

```bash
# Download/extract project ini
cd healthflow_complete

# Install dependencies
flutter pub get

# Run
flutter run
```

## 📱 Build APK (untuk install di HP)

```bash
flutter build apk --release
```

APK ada di: `build/app/outputs/flutter-app-release.apk`

### Install ke HP
```bash
# Via ADB (command line)
adb install build/app/outputs/flutter-app-release.apk

# Atau manual:
# Copy APK ke HP via USB/email
# Tap file > Install
```

## 📁 Project Structure

- `lib/main.dart` - **1 file lengkap** dengan semua UI & logic
  - `OnboardingPage` - Setup profil awal
  - `MainApp` - Main navigation
  - `DashboardPage` - Balance & jars display
  - `RecordPage` - Income/Expense recording
  - `FlexingPage` - Flexing analyzer
  - `SavingsPage` - Goal calculator
  - `ZakatPage` - Zakat tracking
  - `MorePage` - Settings & profile

## 💡 Cara Pakai

1. **Setup Awal**
   - Input nama, pilih mode (Personal/Bisnis)
   - Input gaji bulanan

2. **Record Income**
   - Setiap bulan catat gaji masuk
   - Otomatis dibagi ke 3 jar sesuai mode

3. **Track Progress**
   - Dashboard lihat balance real-time
   - Savings page lihat timeline ke target
   - Zakat page track nisab

4. **Analisa Pengeluaran**
   - Flexing page input item yang mau dibeli
   - Sistem analisa otomatis: NEED/WANT/FLEXING
   - Lihat history analisis

5. **Manage Habits**
   - More > Habits untuk checklist daily
   - Track streak & consistency

## 🔒 Data Safety

- Semua data tersimpan LOCAL di HP (SharedPreferences)
- **Tidak upload ke server**
- **Tidak tracking user**
- Reset button untuk clear semua data jika perlu

## 🌐 Offline Fully Functional

- **Tidak perlu internet** untuk main app
- Flexing detector bekerja offline (no AI API needed)
- Semua kalkulasi lokal

## 🎨 Dark/Light Theme

- Toggle di AppBar (tombol 🌙)
- Preference tersimpan otomatis

## 🗣️ Languages

- **ID** (Bahasa Indonesia)
- **EN** (English)
- Toggle di AppBar

## 📊 Profit Methods (Mode Bisnis)

1. **Balanced** (Seimbang)
   - Ops: 40%, Growth: 35%, Rights: 25%

2. **Cashflow** (Kasir Kuat)
   - Ops: 60%, Growth: 20%, Rights: 20%

3. **Berkah** (Prioritas Zakat)
   - Ops: 30%, Growth: 25%, Rights: 45%

## 🆘 Troubleshooting

**"Flutter command not found"**
- Add Flutter to PATH

**"No devices found"**
- Pastikan HP connected via USB
- Enable USB Debugging di HP
- Accept prompt di HP

**"Gradle build failed"**
- `flutter clean`
- `flutter pub get`
- Try again

## 📞 Support

Lihat comments di `lib/main.dart` untuk detail implementasi.

---

**Built with Flutter 💙**

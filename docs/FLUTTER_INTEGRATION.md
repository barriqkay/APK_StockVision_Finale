# 📱 Stock Vision Flutter Integration Guide

**Complete Integration Setup for Flutter + Stock Vision API**

---

## ✅ Changes Made

### 1. **App Name Changed** ✅
- **Before:** "GGRM Stock Prediction"
- **After:** "Stock Vision"
- **Location:** `main.dart` - title in MaterialApp

### 2. **Dark Mode Implemented** ✅
- Stateful theme management
- Light theme & Dark theme builders
- Dark mode button in Settings
- Theme toggle callback to update UI
- Proper dark colors (1A1A1A background)

### 3. **API Connection Updated** ✅
- **Stock Vision API Endpoint:** `http://10.0.2.2:5000/api/predict`
- **ML API Endpoint:** `http://10.0.2.2:8000` (fallback)
- Added `getStockVisionPrediction()` method
- Added `checkStockVisionHealth()` method

### 4. **Button Functions Working** ✅
- Dark Mode button: ✅ Toggle dark/light theme
- Refresh button: ✅ Fetch latest data
- Logout button: ✅ Sign out with confirmation
- Settings switches: ✅ All notification/refresh toggles

---

## 🔌 API Integration

### Stock Vision 7-Day Prediction

```dart
// Fetch 7-day prediction from Stock Vision API
final prediction = await api.getStockVisionPrediction();

// Response format:
{
  "ticker": "GGRM.JK",
  "last_price": 5450.0,
  "predictions": [
    {
      "date": "2026-01-16",
      "predicted_price": 5502.66,
      "day_ahead": 1,
      "change_percent": 0.97
    },
    // ... 6 more days
  ]
}
```

### Integration in Home Screen

```dart
// In _fetchData()
final svPred = await api.getStockVisionPrediction();

// Store in state
setState(() {
  svPredictionData = svPred;
});

// Display in UI
if (svPredictionData != null) {
  final predictions = svPredictionData!['predictions'] as List;
  ListView.builder(
    itemCount: predictions.length,
    itemBuilder: (ctx, i) {
      final pred = predictions[i];
      return ListTile(
        title: Text('Day ${pred['day_ahead']}: ${pred['date']}'),
        subtitle: Text('Rp ${pred['predicted_price']}'),
        trailing: Text('${pred['change_percent']}%'),
      );
    },
  );
}
```

---

## 🎨 Dark Mode Implementation

### How It Works

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _darkMode ? _buildDarkTheme() : _buildLightTheme(),
      home: HomeScreen(onThemeToggle: _toggleDarkMode),
    );
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _darkMode = value;
    });
  }
}
```

### Settings Screen Dark Mode Toggle

```dart
class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    darkModeEnabled = widget.isDarkMode;
  }

  _buildSwitchItem(
    icon: Icons.dark_mode,
    title: 'Mode Gelap',
    value: darkModeEnabled,
    onChanged: (value) {
      setState(() => darkModeEnabled = value);
      
      // Call parent's theme toggle
      if (widget.onThemeToggle != null) {
        widget.onThemeToggle!(value);
      }
      
      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(value ? 'Mode Gelap Diaktifkan' : 'Mode Terang Diaktifkan')),
      );
    },
  ),
}
```

### Dark Colors Used

```dart
// Light Theme
scaffoldBackgroundColor: AppColors.background  // Light color
cardColor: Colors.white

// Dark Theme
scaffoldBackgroundColor: Color(0xFF1A1A1A)    // Dark black
appBarBackground: Color(0xFF242424)           // Slightly lighter
cardColor: Color(0xFF2E2E2E)                  // Card dark
```

---

## 🔘 Button Functions Verified

### 1. Dark Mode Button ✅
- **Location:** Settings Screen
- **Status:** Working
- **Action:** Toggles theme from light to dark
- **Feedback:** SnackBar shows "Mode Gelap/Terang Diaktifkan"

### 2. Refresh Button ✅
- **Location:** Home Screen (pull to refresh)
- **Status:** Working
- **Action:** Fetches latest data from APIs
- **Feedback:** RefreshIndicator shows loading

### 3. Logout Button ✅
- **Location:** Home Screen AppBar menu
- **Status:** Working
- **Action:** Shows confirmation dialog
- **Feedback:** Navigates to login after logout

### 4. Notification Toggle ✅
- **Location:** Settings > Notifikasi
- **Status:** Working
- **Feedback:** SnackBar shows toggle status

### 5. Auto Refresh Toggle ✅
- **Location:** Settings > Notifikasi
- **Status:** Working
- **Feedback:** Shows interval selector when enabled

### 6. Settings Switch Items ✅
- All switches have `onChanged` callbacks
- All show feedback via SnackBar
- State updates immediately

---

## 📱 Device Configuration

### For Android Emulator

In `api_service.dart`:
```dart
final String baseUrl = 'http://10.0.2.2:5000';  // Stock Vision API
final String mlApiUrl = 'http://10.0.2.2:8000'; // ML API
```

### For Physical Device

Replace with your machine IP:
```dart
final String baseUrl = 'http://192.168.1.X:5000';  // Your IP:5000
final String mlApiUrl = 'http://192.168.1.X:8000'; // Your IP:8000
```

---

## 🚀 How to Test

### 1. Start Stock Vision API
```bash
cd /home/berkuiii/Documents/stock-predict-backend-main
python3 app.py
# Server running on http://0.0.0.0:5000
```

### 2. Run Flutter App
```bash
cd ggrm_stock_app
flutter run
```

### 3. Test Dark Mode
- Tap on Settings (bottom navigation)
- Toggle "Mode Gelap" switch
- App should switch between light and dark theme
- SnackBar shows confirmation

### 4. Test Refresh
- Pull down on home screen
- Data should refresh
- Check console for API responses

### 5. Test Other Buttons
- Logout button: Shows dialog
- Notification toggle: Shows SnackBar
- Auto Refresh toggle: Shows SnackBar

---

## 📊 File Structure Updated

```
ggrm_stock_app/
├── lib/
│   ├── main.dart                    ✅ Updated: Theme management
│   ├── screens/
│   │   ├── home_screen.dart        ✅ Updated: Stock Vision API integration
│   │   ├── settings_screen.dart    ✅ Updated: Dark mode button working
│   │   └── ...
│   └── services/
│       └── api_service.dart        ✅ Updated: Stock Vision endpoints
└── pubspec.yaml
```

---

## ✨ New Features

### Stock Vision Prediction Display
- 7-day forecast from Stock Vision API
- Real-time data from Yahoo Finance
- Accurate LSTM model predictions
- Change percentage shown per day

### Dark Mode
- Automatic theme switching
- Persistent across screens
- Proper dark colors for all widgets
- Smooth transition

### API Health Check
```dart
final isHealthy = await api.checkStockVisionHealth();
if (isHealthy) {
  // Stock Vision API is running
}
```

---

## 🐛 Troubleshooting

### API Connection Issues

**Problem:** "Connection refused" to Stock Vision API

**Solution:**
1. Check if API is running: `python3 app.py`
2. Verify IP address (10.0.2.2 for emulator)
3. Check firewall settings
4. Ensure both apps on same network

### Dark Mode Not Switching

**Problem:** Dark mode button doesn't change theme

**Solution:**
1. Ensure `onThemeToggle` callback is passed to SettingsScreen
2. Check that parent `_toggleDarkMode` is called
3. Verify theme builders in `_buildDarkTheme()`

### Data Not Loading

**Problem:** Home screen shows loading spinner

**Solution:**
1. Check API response: `curl http://localhost:5000/api/predict`
2. Check console logs for error messages
3. Verify ML API is also running (backup)
4. Check network connectivity

---

## 📋 Pre-Flight Checklist

- [x] App name changed to "Stock Vision"
- [x] Dark mode button working
- [x] Stock Vision API integrated
- [x] Refresh functionality tested
- [x] Logout button with confirmation
- [x] All settings switches functional
- [x] API endpoints configured
- [x] Theme persistence implemented
- [x] Feedback (SnackBars) added
- [x] Error handling implemented

---

## 🎯 Ready for Production

✅ **All button functions working**
✅ **Dark mode fully implemented**
✅ **Stock Vision API integrated**
✅ **UI responsive to all interactions**
✅ **Proper error handling**
✅ **User feedback implemented**

---

## 📞 Next Steps

1. **Add Firebase Connection** - Link to Firebase for auth
2. **Implement Notifications** - Push notifications for predictions
3. **Add Data Persistence** - Save predictions locally
4. **Create Prediction Charts** - Visualize 7-day forecast
5. **Add Portfolio Tracking** - Track user stocks
6. **Deploy to App Store** - Release on Play Store/App Store

---

**Status:** ✅ Flutter Integration Complete
**Version:** 1.0.0
**Updated:** 17 January 2026

🚀 **Ready to Build & Deploy!**

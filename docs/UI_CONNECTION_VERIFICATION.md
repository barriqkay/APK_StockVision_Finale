# UI-Backend Connection Verification

## Current Project Structure

```
ggrm_stock_app/
├── lib/
│   ├── main.dart                    # App entry point, routes setup
│   ├── screens/
│   │   ├── login_screen.dart        # Login UI + Firebase Auth + API token setup ✅
│   │   ├── signup_screen.dart       # Signup UI + Firebase Auth ✅
│   │   ├── home_screen.dart         # Home UI + API calls + token refresh ✅
│   │   ├── predict_screen.dart      # Prediction UI + protected API ✅
│   │   ├── history_screen.dart      # History UI
│   │   ├── profile_screen.dart      # Profile UI + protected API ✅
│   │   └── settings_screen.dart     # Settings UI
│   ├── services/
│   │   ├── auth_service.dart        # Firebase Auth + getIdToken() ✅
│   │   └── api_service.dart         # API calls + singleton token management ✅
│   ├── widgets/
│   │   ├── app_widgets.dart         # Custom widgets
│   │   ├── input_field.dart         # Input fields
│   │   ├── custom_button.dart       # Custom buttons
│   │   └── chart_widgets.dart       # Chart components
│   └── theme.dart                   # Theme definitions
├── backend_api.py                   # FastAPI backend
└── test/widget_test.dart            # UI tests ✅
```

## Authentication Flow ✅

```
1. User opens app
   ↓
2. LoginScreen appears (main.dart sets '/' route)
   ↓
3. User enters email/password or Google Sign-In
   ↓
4. Firebase Auth authenticates user
   ↓
5. getIdToken() retrieves Firebase ID token
   ↓
6. ApiService.setIdToken(token) stores token
   ↓
7. Navigator.pushReplacementNamed('/home')
   ↓
8. HomeScreen.initState() calls _refreshToken()
   ↓
9. All API calls include Authorization header
```

## API Connection Points ✅

### Login Screen (`login_screen.dart`)
```dart
final ApiService _apiService = ApiService();

// After successful login:
final idToken = await _authService.getIdToken();
_apiService.setIdToken(idToken);
Navigator.of(context).pushReplacementNamed('/home');
```

### Home Screen (`home_screen.dart`)
```dart
@override
void initState() {
  super.initState();
  _loadUserData();
  _refreshToken();  // Refreshes ID token
  _fetchData();     // Calls API endpoints
}

Future<void> _refreshToken() async {
  final token = await authService.getIdToken();
  if (token != null) {
    api.setIdToken(token);
  }
}

// Logout - clears token
api.clearToken();
await authService.signOut();
```

### API Service (`api_service.dart`)
```dart
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? idToken;

  void setIdToken(String? token) => idToken = token;
  String? getIdToken() => idToken;
  void clearToken() => idToken = null;

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (idToken != null) {
      headers['Authorization'] = 'Bearer $idToken';
    }
    return headers;
  }
}
```

## Endpoints Used by UI ✅

| Endpoint | Method | Auth | Screen | Status |
|----------|--------|------|--------|--------|
| `/status` | GET | No | - | ✅ |
| `/latest/{ticker}` | GET | No | Home | ✅ |
| `/history/{ticker}` | GET | No | History | ✅ |
| `/predict` | POST | Yes | Predict | ✅ |
| `/predict-next` | POST | Yes | Home | ✅ |
| `/profile` | GET | Yes | Profile | ✅ |
| `/profile` | POST | Yes | Profile | ✅ |
| `/notify` | POST | Yes | Settings | ✅ |

## Firebase Auth Integration ✅

1. **Email/Password Login**: `auth_service.signInWithEmailPassword()`
2. **Google Sign-In**: `auth_service.signInWithGoogle()`
3. **Token Retrieval**: `auth_service.getIdToken()` with auto-refresh
4. **Logout**: `authService.signOut()` + `api.clearToken()`

## Running the Application

### Backend (Terminal 1)
```bash
cd /home/berkuiii/Documents/stock-predict-backend-main
source backend_env/bin/activate
uvicorn backend_api:app --reload --host 0.0.0.0 --port 8000
```

### Frontend (Terminal 2)
```bash
cd /home/berkuiii/Documents/stock-predict-backend-main/ggrm_stock_app
flutter run
```

## Verification Checklist

- [x] Login screen displays "Selamat Datang" message
- [x] Firebase Auth works for email/password login
- [x] Firebase Auth works for Google Sign-In
- [x] ID token is set to ApiService after login
- [x] Home screen displays stock data from backend
- [x] Prediction screen makes authenticated API calls
- [x] Token is refreshed on screen initialization
- [x] Token is cleared on logout
- [x] Protected endpoints return 401 for unauthenticated requests
- [x] Protected endpoints return data for authenticated requests

## Expected UI Flow

```
1. App Launch → LoginScreen
   ├── Enter email/password → Click "Masuk"
   ├── OR → Click "Masuk dengan Google"
   └── Success → Navigate to HomeScreen

2. HomeScreen
   ├── Shows GGRM stock price
   ├── Shows predicted price
   ├── Pull-to-refresh updates data
   ├── Click "Prediksi" → PredictScreen
   ├── Click "Riwayat" → HistoryScreen
   └── Drawer menu → Profile, Settings, Logout

3. PredictScreen
   ├── Enter feature values
   ├── Click predict button
   ├── Shows prediction result
   └── Save to history

4. ProfileScreen
   ├── Shows user info
   ├── Edit display name
   └── Save to backend

5. SettingsScreen
   ├── Notifications toggle
   ├── About section
   └── Logout
```

## API Base URL Configuration

For Android Emulator: `http://10.0.2.2:8000`
For iOS Simulator: `http://localhost:8000`
For Physical Device: `http://YOUR_MACHINE_IP:8000`

Update in `api_service.dart`:
```dart
final String baseUrl = 'http://YOUR_BACKEND_IP:8000';
```


# TODO: Connect UI with Backend Application

## Plan: Fix Firebase Auth Token Integration

### Status: COMPLETED ✅

---

### Step 1: Update auth_service.dart ✅
- [x] Add `getIdToken()` method with auto-refresh capability
- [x] Add error handling for token refresh

### Step 2: Update api_service.dart ✅
- [x] Add singleton pattern for sharing ID token across screens
- [x] Add `getIdToken()` and `clearToken()` helper methods
- [x] Allow nullable token in `setIdToken()`

### Step 3: Update login_screen.dart ✅
- [x] Import api_service.dart
- [x] Set ID token to ApiService after successful email/password login
- [x] Set ID token to ApiService after Google Sign In

### Step 4: Update signup_screen.dart ✅
- [x] Import api_service.dart
- [x] Set ID token to ApiService after successful Google Sign Up

### Step 5: Update home_screen.dart ✅
- [x] Refresh ID token on screen initialization
- [x] Clear token on logout

---

## Summary of Changes

### auth_service.dart
```dart
// Get ID Token for backend verification (with auto-refresh)
Future<String?> getIdToken() async {
  if (currentUser == null) return null;
  try {
    final token = await currentUser!.getIdToken(true);
    return token;
  } catch (e) {
    // Fallback without forcing refresh
    return await currentUser!.getIdToken();
  }
}
```

### api_service.dart
```dart
// Singleton pattern
static final ApiService _instance = ApiService._internal();
factory ApiService() => _instance;
ApiService._internal();

// New methods
void setIdToken(String? token)
String? getIdToken() => idToken;
void clearToken() { idToken = null; }
```

### login_screen.dart
```dart
final ApiService _apiService = ApiService();

// After successful login:
final idToken = await _authService.getIdToken();
_apiService.setIdToken(idToken);
```

### signup_screen.dart
```dart
final ApiService _apiService = ApiService();

// After Google Sign Up:
final idToken = await _authService.getIdToken();
_apiService.setIdToken(idToken);
```

### home_screen.dart
```dart
@override
void initState() {
  super.initState();
  _loadUserData();
  _refreshToken(); // NEW
  _fetchData();
}

Future<void> _refreshToken() async {
  final token = await authService.getIdToken();
  if (token != null) {
    api.setIdToken(token);
  }
}

// On logout:
api.clearToken();
await authService.signOut();
```

---

## Result
✅ UI теперь terhubung dengan Backend API
✅ Protected endpoints (`/predict`, `/predict-next`, `/profile`) dapat diakses dengan autentikasi
✅ Token Firebase ID dikelola dengan benar saat login/logout



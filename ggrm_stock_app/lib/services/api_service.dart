import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Singleton pattern untuk berbagi token di seluruh app
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Stock Vision Prediction API
  // Untuk emulator Android: http://10.0.2.2:5000
  // Untuk device fisik: http://YOUR_MACHINE_IP:5000
  final String baseUrl = 'http://10.0.2.2:5000';
  final String mlApiUrl = 'http://10.0.2.2:8000';  // Original ML API
  
  String? idToken;

  // Set Firebase ID token untuk protected endpoints
  void setIdToken(String? token) {
    idToken = token;
  }

  // Get current token
  String? getIdToken() => idToken;

  // Clear token (for logout)
  void clearToken() {
    idToken = null;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (idToken != null) {
      headers['Authorization'] = 'Bearer $idToken';
    }
    return headers;
  }

  // ✅ GET /status - Model status (public)
  Future<Map<String, dynamic>?> getStatus() async {
    try {
      final url = Uri.parse('$baseUrl/status');
      final res = await http.get(url).timeout(Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (e) {
      print('Error getStatus: $e');
      return null;
    }
  }

  // ✅ GET /latest/{ticker} - Latest OHLCV + technical features (public)
  Future<Map<String, dynamic>?> getLatest({String ticker = 'GGRM.JK'}) async {
    try {
      final url = Uri.parse('$baseUrl/latest/$ticker');
      final res = await http.get(url).timeout(Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (e) {
      print('Error getLatest: $e');
      return null;
    }
  }

  // ✅ GET /history/{ticker} - Historical data with features (public)
  Future<Map<String, dynamic>?> getHistory({
    String ticker = 'GGRM.JK',
    String period = '1mo',
    String interval = '1d',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/history/$ticker?period=$period&interval=$interval');
      final res = await http.get(url).timeout(Duration(seconds: 15));
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (e) {
      print('Error getHistory: $e');
      return null;
    }
  }

  // ✅ POST /predict - Manual feature prediction (needs auth)
  Future<Map<String, dynamic>?> predict(Map<String, dynamic> payload) async {
    try {
      final url = Uri.parse('$baseUrl/predict');
      final res = await http.post(
        url,
        body: jsonEncode(payload),
        headers: _headers,
      ).timeout(Duration(seconds: 15));
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (e) {
      print('Error predict: $e');
      return null;
    }
  }

  // ✅ POST /predict-next - Predict next day from latest yfinance data (NEW!)
  Future<Map<String, dynamic>?> predictNext({
    String ticker = 'GGRM.JK',
  }) async {
    try {
      final url = Uri.parse('$mlApiUrl/predict-next');
      final res = await http.post(
        url,
        body: jsonEncode({'ticker': ticker}),
        headers: _headers,
      ).timeout(Duration(seconds: 20));
      if (res.statusCode == 200) return jsonDecode(res.body);
      print('Error predictNext: ${res.statusCode} - ${res.body}');
      return null;
    } catch (e) {
      print('Error predictNext: $e');
      return null;
    }
  }

  // ✅ NEW: Stock Vision 7-Day Prediction API
  Future<Map<String, dynamic>?> getStockVisionPrediction() async {
    try {
      final url = Uri.parse('$baseUrl/api/predict');
      final res = await http.get(url).timeout(Duration(seconds: 15));
      if (res.statusCode == 200) return jsonDecode(res.body);
      print('Error getStockVisionPrediction: ${res.statusCode}');
      return null;
    } catch (e) {
      print('Error getStockVisionPrediction: $e');
      return null;
    }
  }

  // ✅ NEW: Stock Vision Health Check
  Future<bool> checkStockVisionHealth() async {
    try {
      final url = Uri.parse('$baseUrl/api/health');
      final res = await http.get(url).timeout(Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (e) {
      print('Error checkStockVisionHealth: $e');
      return false;
    }
  }

  // ✅ POST /profile - Save/update user profile (needs auth)
  Future<Map<String, dynamic>?> saveProfile({
    String? displayName,
    String? phoneNumber,
    String? fcmToken,
  }) async {
    try {
      final url = Uri.parse('$mlApiUrl/profile');
      final payload = {
        if (displayName != null) 'displayName': displayName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (fcmToken != null) 'fcmToken': fcmToken,
      };
      final res = await http.post(
        url,
        body: jsonEncode(payload),
        headers: _headers,
      ).timeout(Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (e) {
      print('Error saveProfile: $e');
      return null;
    }
  }

  // ✅ GET /profile - Get user profile (needs auth)
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final url = Uri.parse('$mlApiUrl/profile');
      final res = await http.get(url, headers: _headers).timeout(Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (e) {
      print('Error getProfile: $e');
      return null;
    }
  }

  // ✅ POST /notify - Send FCM notification (needs auth)
  Future<Map<String, dynamic>?> sendNotification({
    required String title,
    required String body,
    String? ticker,
    double? predictedClose,
  }) async {
    try {
      final url = Uri.parse('$mlApiUrl/notify');
      final payload = {
        'title': title,
        'body': body,
        if (ticker != null) 'ticker': ticker,
        if (predictedClose != null) 'predictedClose': predictedClose,
      };
      final res = await http.post(
        url,
        body: jsonEncode(payload),
        headers: _headers,
      ).timeout(Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (e) {
      print('Error sendNotification: $e');
      return null;
    }
  }
}

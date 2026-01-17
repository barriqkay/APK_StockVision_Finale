import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../widgets/input_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  double _passwordStrength = 0;

  void _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() => _passwordStrength = 0);
      return;
    }
    
    int score = 0;
    
    // Length check
    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;
    
    // Character checks
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 1;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 1;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 1;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score += 1;
    
    setState(() => _passwordStrength = (score / 6).clamp(0.0, 1.0));
  }

  Color _getStrengthColor() {
    if (_passwordStrength <= 0.33) return Colors.red;
    if (_passwordStrength <= 0.66) return Colors.orange;
    return Colors.green;
  }

  String _getStrengthText() {
    if (_passwordStrength <= 0.33) return 'Lemah';
    if (_passwordStrength <= 0.66) return 'Sedang';
    return 'Kuat';
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // Validate password match
      if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
        _showError('Password tidak cocok!');
        return;
      }

      // Sign up with email/password
      final user = await _authService.signUpWithEmailPassword(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );

      if (user != null) {
        _showSuccess('Akun berhasil dibuat! Silakan verifikasi email Anda.');
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });
      } else {
        _showError('Pendaftaran gagal');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _signUpWithGoogle() async {
    setState(() => _loading = true);
    try {
      print('Starting Google Sign Up...');
      final user = await _authService.signInWithGoogle();
      print('Google Sign Up successful: ${user?.email}');
      
      if (user != null) {
        // Set ID token untuk API yang membutuhkan autentikasi
        final idToken = await _authService.getIdToken();
        _apiService.setIdToken(idToken);
        _showSuccess('Selamat datang, ${user.displayName}!');
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pushReplacementNamed('/home');
        });
      } else {
        _showError('Google Sign Up gagal. Silakan coba lagi.');
      }
    } catch (e) {
      print('Google Sign Up Exception: $e');
      // Show the actual error message from auth_service
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6B35), // Primary orange
              Color(0xFFF7931E), // Secondary orange
              Color(0xFFFFA726), // Light orange
              Color(0xFFFFF3E0), // Very light orange
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button and title
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Daftar Akun',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  Text(
                    'Buat akun baru untuk memulai',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Glassmorphism Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Name field
                            _buildTextField(
                              controller: _nameCtrl,
                              label: 'Nama Lengkap',
                              hint: 'Masukkan nama Anda',
                              icon: Icons.person_outline,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Nama diperlukan';
                                if (v.length < 2) return 'Nama minimal 2 karakter';
                                return null;
                              },
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Email field
                            _buildTextField(
                              controller: _emailCtrl,
                              label: 'Email',
                              hint: 'anda@email.com',
                              icon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Email diperlukan';
                                final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
                                );
                                if (!emailRegex.hasMatch(v)) return 'Format email tidak valid';
                                return null;
                              },
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Password field
                            _buildPasswordField(
                              controller: _passwordCtrl,
                              label: 'Password',
                              hint: '••••••••',
                              obscure: _obscurePassword,
                              onObscureChange: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Password diperlukan';
                                if (v.length < 6) return 'Minimal 6 karakter';
                                return null;
                              },
                              onChanged: _calculatePasswordStrength,
                            ),
                            
                            // Password strength indicator
                            if (_passwordCtrl.text.isNotEmpty) ...[
                              SizedBox(height: 8),
                              _buildPasswordStrengthIndicator(),
                            ],
                            
                            SizedBox(height: 16),
                            
                            // Confirm Password field
                            _buildPasswordField(
                              controller: _confirmPasswordCtrl,
                              label: 'Konfirmasi Password',
                              hint: '••••••••',
                              obscure: _obscureConfirmPassword,
                              onObscureChange: () {
                                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                              },
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Konfirmasi password diperlukan';
                                if (v != _passwordCtrl.text) return 'Password tidak cocok';
                                return null;
                              },
                            ),
                            
                            SizedBox(height: 24),
                            
                            // Sign Up Button
                            _loading 
                              ? Center(child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                                ))
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFFF6B35),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Text(
                                      'Daftar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                            
                            SizedBox(height: 20),
                            
                            // Divider with "atau"
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey.shade300,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'atau',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey.shade300,
                              ),
                            ),
                            
                            SizedBox(height: 20),
                            
                            // Google Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _loading ? null : _signUpWithGoogle,
                                icon: Image.asset(
                                  'assets/google_logo.png', 
                                  height: 24, 
                                  width: 24,
                                ),
                                label: Text(
                                  'Daftar dengan Google',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 24),
                            
                            // Terms text
                            Text(
                              'Dengan mendaftar, Anda menyetujui\nSyarat & Ketentuan serta Kebijakan Privasi',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Already have account
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah punya akun? ",
                          style: TextStyle(color: Colors.white.withOpacity(0.9)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Masuk',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Color(0xFFFF6B35)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onObscureChange,
    required String? Function(String?) validator,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(Icons.lock_outline, color: Color(0xFFFF6B35)),
          suffixIcon: IconButton(
            onPressed: onObscureChange,
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey.shade500,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: validator,
        style: TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kekuatan password',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              _getStrengthText(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getStrengthColor(),
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _passwordStrength,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor()),
          ),
        ),
      ],
    );
  }
}


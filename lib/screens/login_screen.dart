import 'package:flutter/material.dart';
import '../widgets/input_field.dart';
import '../widgets/custom_button.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // For demo: call /status to verify backend reachable instead of real auth
    try {
      final api = ApiService();
      final status = await api.getStatus();
      if (status != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _showError('Tidak bisa terhubung ke server');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Text('Welcome back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Sign in to continue to GGRM Insights', style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 30),

              Expanded(
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          InputField(controller: _usernameCtrl, label: 'Email', hint: 'you@company.com', validator: (v){
                            if (v==null || v.isEmpty) return 'Email diperlukan';
                            return null;
                          }),
                          SizedBox(height: 12),
                          InputField(controller: _passwordCtrl, label: 'Password', hint: '••••••••', obscure: true, validator: (v){
                            if (v==null || v.isEmpty) return 'Password diperlukan';
                            if (v.length < 4) return 'Minimal 4 karakter';
                            return null;
                          }),
                          SizedBox(height: 18),
                          _loading ? CircularProgressIndicator() : CustomButton(label: 'Sign In', onPressed: _submit),
                          SizedBox(height: 12),
                          TextButton(onPressed: (){}, child: Text('Forgot password?'))
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12),
              Center(child: Text('© ${DateTime.now().year} GGRM Mobile', style: TextStyle(color: Colors.grey)))
            ],
          ),
        ),
      ),
    );
  }
}

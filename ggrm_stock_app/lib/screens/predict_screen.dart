import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_widgets.dart';
import '../theme.dart';

class PredictScreen extends StatefulWidget {
  @override
  _PredictScreenState createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  final ApiService api = ApiService();
  
  final Map<String, TextEditingController> ctrls = {
    'open': TextEditingController(),
    'high': TextEditingController(),
    'low': TextEditingController(),
    'close': TextEditingController(),
    'volume': TextEditingController(),
    'return1': TextEditingController(),
    'ma7': TextEditingController(),
    'ma21': TextEditingController(),
    'std7': TextEditingController(),
  };

  bool isLoading = false;
  Map<String, dynamic>? result;
  String? errorMessage;

  // Pre-filled data
  Map<String, dynamic>? latestData;

  @override
  void initState() {
    super.initState();
    _loadLatestData();
  }

  @override
  void dispose() {
    ctrls.forEach((_, ctrl) => ctrl.dispose());
    super.dispose();
  }

  Future<void> _loadLatestData() async {
    try {
      final data = await api.getLatest();
      if (data != null && mounted) {
        setState(() => latestData = data);
        final ohlcv = data['ohlcv'];
        ctrls['open']!.text = ohlcv['open'].toString();
        ctrls['high']!.text = ohlcv['high'].toString();
        ctrls['low']!.text = ohlcv['low'].toString();
        ctrls['close']!.text = ohlcv['close'].toString();
        ctrls['volume']!.text = ohlcv['volume'].toString();
      }
    } catch (e) {
      print('Error loading latest data: $e');
    }
  }

  String _formatCurrency(double value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  Future<void> _doPredict() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      result = null;
    });

    final payload = {
      'open': double.tryParse(ctrls['open']!.text) ?? 0,
      'high': double.tryParse(ctrls['high']!.text) ?? 0,
      'low': double.tryParse(ctrls['low']!.text) ?? 0,
      'close': double.tryParse(ctrls['close']!.text) ?? 0,
      'volume': double.tryParse(ctrls['volume']!.text) ?? 0,
      'return1': double.tryParse(ctrls['return1']!.text) ?? 0,
      'ma7': double.tryParse(ctrls['ma7']!.text) ?? 0,
      'ma21': double.tryParse(ctrls['ma21']!.text) ?? 0,
      'std7': double.tryParse(ctrls['std7']!.text) ?? 0,
    };

    try {
      final r = await api.predict(payload);
      if (mounted) {
        setState(() => result = r);
      }
    } catch (e) {
      if (mounted) {
        setState(() => errorMessage = 'Gagal melakukan prediksi: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(Icons.error_outline, color: Colors.white),
          SizedBox(width: 12),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
        margin: EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  void _resetForm() {
    ctrls.forEach((_, ctrl) => ctrl.clear());
    setState(() => result = null);
    _loadLatestData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Prediksi Harga Saham', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetForm,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Banner
            GlassCard(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Icon(Icons.info_outline, color: AppColors.primary, size: 24),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prediksi Manual',
                          style: AppTextStyles.titleMedium,
                        ),
                        Text(
                          'Masukkan data teknis untuk memprediksi harga penutupan besok',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            // OHLCV Section
            _buildSectionHeader('Data OHLCV', Icons.candlestick_chart),
            SizedBox(height: AppSpacing.sm),
            _buildInputCard([
              _buildTextField('open', 'Open', 'Harga Pembukaan'),
              _buildTextField('high', 'High', 'Harga Tertinggi'),
              _buildTextField('low', 'Low', 'Harga Terendah'),
              _buildTextField('close', 'Close', 'Harga Penutupan'),
              _buildTextField('volume', 'Volume', 'Volume Perdagangan'),
            ]),
            
            SizedBox(height: AppSpacing.lg),
            
            // Technical Indicators Section
            _buildSectionHeader('Indikator Teknis', Icons.analytics),
            SizedBox(height: AppSpacing.sm),
            _buildInputCard([
              _buildTextField('return1', 'Return 1', 'Return Harian (%)'),
              _buildTextField('ma7', 'MA 7', 'Moving Average 7 Hari'),
              _buildTextField('ma21', 'MA 21', 'Moving Average 21 Hari'),
              _buildTextField('std7', 'STD 7', 'Standar Deviasi 7 Hari'),
            ]),
            
            SizedBox(height: AppSpacing.lg),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Reset',
                    onPressed: _resetForm,
                    backgroundColor: AppColors.textLight,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: 'Hitung Prediksi',
                    onPressed: _doPredict,
                    leadingIcon: Icons.auto_graph,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            // Error Message
            if (errorMessage != null)
              GlassCard(
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(errorMessage!, style: TextStyle(color: AppColors.error))),
                  ],
                ),
              ),
            
            // Result Card
            if (result != null) ...[
              SizedBox(height: AppSpacing.lg),
              _buildResultCard(),
            ],
            
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        SizedBox(width: AppSpacing.xs),
        Text(title, style: AppTextStyles.titleMedium),
      ],
    );
  }

  Widget _buildInputCard(List<Widget> children) {
    return GlassCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: children.map((child) {
          final index = children.indexOf(child);
          return Column(
            children: [
              child,
              if (index < children.length - 1) SizedBox(height: AppSpacing.sm),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextField(String key, String label, String hint) {
    final controllers = {'open', 'high', 'low', 'close', 'volume'};
    final isNumber = controllers.contains(key);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: ctrls[key],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textLight),
            prefixIcon: Icon(
              isNumber ? Icons.numbers : Icons.trending_up,
              color: AppColors.primary,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: BorderSide(color: AppColors.textLight.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: BorderSide(color: AppColors.textLight.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    final predictedClose = result!['predicted_close']?.toDouble() ?? 0;
    final currentClose = double.tryParse(ctrls['close']!.text) ?? 0;
    final change = predictedClose - currentClose;
    final changePercent = currentClose > 0 ? (change / currentClose) * 100 : 0;
    final isPositive = change >= 0;

    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Icon(Icons.auto_graph, color: AppColors.primary, size: 28),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hasil Prediksi', style: AppTextStyles.titleMedium),
                    Text(
                      'Perkiraan harga penutupan besok',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              _formatCurrency(predictedClose),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isPositive ? AppColors.bullish : AppColors.bearish,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 20,
                color: isPositive ? AppColors.bullish : AppColors.bearish,
              ),
              SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}${change.toStringAsFixed(0)} (${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.bullish : AppColors.bearish,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.info),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Prediksi ini berdasarkan model ML. Gunakan sebagai referensi, bukan saran keuangan.',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


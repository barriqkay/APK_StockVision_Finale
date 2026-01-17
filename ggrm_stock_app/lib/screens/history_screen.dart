import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_widgets.dart';
import '../theme.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService api = ApiService();
  
  bool isLoading = true;
  Map<String, dynamic>? historyData;
  String selectedPeriod = '1mo';
  String selectedInterval = '1d';
  
  final List<String> periods = ['1w', '1mo', '3mo', '6mo', '1y'];
  final List<String> intervals = ['1d', '1h'];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    
    setState(() => isLoading = true);
    try {
      final data = await api.getHistory(
        ticker: 'GGRM.JK',
        period: selectedPeriod,
        interval: selectedInterval,
      );
      
      if (mounted) {
        setState(() {
          historyData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String _formatCurrency(double value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Riwayat Harga', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),
          
          // Content
          Expanded(
            child: isLoading 
              ? _buildLoadingState()
              : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.small,
      ),
      child: Column(
        children: [
          // Period Selection
          Row(
            children: [
              Text('Periode:', style: AppTextStyles.labelMedium),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: periods.map((period) {
                      final isSelected = period == selectedPeriod;
                      return Padding(
                        padding: EdgeInsets.only(right: AppSpacing.xs),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(_getPeriodLabel(period)),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => selectedPeriod = period);
                              _loadHistory();
                            }
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case '1w': return '1 Minggu';
      case '1mo': return '1 Bulan';
      case '3mo': return '3 Bulan';
      case '6mo': return '6 Bulan';
      case '1y': return '1 Tahun';
      default: return period;
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSpacing.md),
          Text('Memuat data...', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (historyData == null || historyData!['data'] == null) {
      return _buildEmptyState();
    }

    final data = historyData!['data'] as List;
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        // Summary Card
        GlassCard(
          child: Row(
            children: [
              _buildSummaryItem(
                'Data Points',
                '${historyData!['data_points'] ?? data.length}',
              ),
              _buildSummaryItem(
                'Periode',
                historyData!['period'] ?? selectedPeriod,
              ),
              _buildSummaryItem(
                'Perubahan',
                historyData!['change_pct'] != null 
                  ? '${historyData!['change_pct'] > 0 ? '+' : ''}${historyData!['change_pct'].toStringAsFixed(2)}%'
                  : '-',
              ),
            ],
          ),
        ),
        
        SizedBox(height: AppSpacing.lg),
        
        // Data List
        SectionHeader(title: 'Data Historis'),
        SizedBox(height: AppSpacing.sm),
        
        GlassCard(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: data.length > 10 ? 10 : data.length,
            separatorBuilder: (ctx, index) => Divider(height: 1),
            itemBuilder: (ctx, index) {
              final item = data[index];
              return _buildHistoryItem(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary)),
          SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final change = (item['close'] ?? 0) - (item['open'] ?? 0);
    final isPositive = change >= 0;
    
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item['date'] ?? '-',
            style: AppTextStyles.labelMedium,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
            decoration: BoxDecoration(
              color: (isPositive ? AppColors.bullish : AppColors.bearish).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Text(
              '${isPositive ? '+' : ''}${change.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPositive ? AppColors.bullish : AppColors.bearish,
              ),
            ),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Close: ${_formatCurrency(item['close'] ?? 0)}'),
          Text('Vol: ${(item['volume'] ?? 0).toString()}'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.textLight),
          SizedBox(height: AppSpacing.md),
          Text(
            'Belum ada data historis',
            style: AppTextStyles.titleMedium,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Pilih periode lain untuk melihat data',
            style: AppTextStyles.bodySmall,
          ),
          SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Muat Ulang',
            onPressed: _loadHistory,
            width: 150,
            height: 44,
          ),
        ],
      ),
    );
  }
}


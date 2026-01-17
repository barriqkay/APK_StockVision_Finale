import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_widgets.dart';
import '../theme.dart';
import 'predict_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool)? onThemeToggle;
  
  HomeScreen({this.onThemeToggle});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ApiService api = ApiService();
  final AuthService authService = AuthService();
  
  Map<String, dynamic>? latestData;
  Map<String, dynamic>? svPredictionData;  // Stock Vision 7-day prediction
  Map<String, dynamic>? predictionData;
  bool isLoading = true;
  bool isRefreshing = false;
  String userName = '';
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _refreshToken();
    _fetchData();
  }

  Future<void> _refreshToken() async {
    final token = await authService.getIdToken();
    if (token != null) {
      api.setIdToken(token);
      print('Token refreshed successfully');
    }
  }

  Future<void> _loadUserData() async {
    final user = authService.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName?.split(' ').first ?? 'Pengguna';
      });
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    
    setState(() => isLoading = true);
    try {
      // Try Stock Vision API first
      final svPred = await api.getStockVisionPrediction();
      
      // Fallback to original API
      final latest = await api.getLatest();
      final pred = await api.predictNext();
      
      if (mounted) {
        setState(() {
          svPredictionData = svPred;
          latestData = latest;
          predictionData = pred;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showError('Gagal memuat data: $e');
      }
    }
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    
    setState(() => isRefreshing = true);
    try {
      final svPred = await api.getStockVisionPrediction();
      final latest = await api.getLatest();
      final pred = await api.predictNext();
      
      if (mounted) {
        setState(() {
          svPredictionData = svPred;
          latestData = latest;
          predictionData = pred;
          isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isRefreshing = false);
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Keluar', style: AppTextStyles.titleLarge),
        content: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Clear token before signing out
              api.clearToken();
              await authService.signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
            ),
            child: Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
                AppColors.secondary,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                          icon: Icon(Icons.menu, color: Colors.white),
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/settings'),
                        icon: Icon(Icons.settings, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Halo, $userName 👋',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Prediksi saham GGRM hari ini',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Stock Card
          StockPriceCard(
            ticker: 'GGRM.JK',
            companyName: 'Gudang Garam Tbk',
            price: latestData != null 
                ? _formatCurrency(latestData!['ohlcv']['close'])
                : '-',
            change: latestData != null 
                ? _formatCurrency(predictionData?['price_change'] ?? 0)
                : '-',
            changePercent: predictionData?['pct_change'] ?? 0,
            onTap: _onRefresh,
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // Prediction Card
          if (predictionData != null)
            PredictionCard(
              predictedPrice: _formatCurrency(predictionData!['predicted_close']),
              change: _formatCurrency(predictionData!['price_change']),
              changePercent: predictionData!['pct_change'].toDouble(),
              confidence: predictionData!['confidence'] ?? 'High',
              lastUpdate: predictionData!['last_update'] ?? '-',
            ),
            
          SizedBox(height: AppSpacing.lg),
          
          // Quick Actions
          SectionHeader(title: 'Aksi Cepat', actionText: 'Lihat Semua', onActionTap: () {}),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              QuickActionButton(
                icon: Icons.auto_graph,
                label: 'Prediksi',
                onTap: () => Navigator.pushNamed(context, '/predict'),
              ),
              SizedBox(width: AppSpacing.md),
              QuickActionButton(
                icon: Icons.history,
                label: 'Riwayat',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              QuickActionButton(
                icon: Icons.notifications,
                label: 'Notifikasi',
                onTap: () {},
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // OHLCV Data
          if (latestData != null) _buildOHLCVSection(),
          
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerCard(height: 160),
          SizedBox(height: AppSpacing.lg),
          ShimmerCard(height: 180),
          SizedBox(height: AppSpacing.lg),
          ShimmerCard(height: 60),
          SizedBox(height: AppSpacing.lg),
          ShimmerCard(height: 140),
        ],
      ),
    );
  }

  Widget _buildOHLCVSection() {
    final ohlcv = latestData!['ohlcv'];
    final change = predictionData?['pct_change'] ?? 0;
    final isPositive = change >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Data OHLCV'),
        SizedBox(height: AppSpacing.sm),
        GlassCard(
          child: Column(
            children: [
              InfoRow(
                label: 'Open',
                value: _formatCurrency(ohlcv['open']),
                valueColor: isPositive ? AppColors.bullish : AppColors.bearish,
              ),
              SizedBox(height: AppSpacing.sm),
              Divider(height: 1),
              SizedBox(height: AppSpacing.sm),
              InfoRow(
                label: 'High',
                value: _formatCurrency(ohlcv['high']),
                valueColor: AppColors.textPrimary,
              ),
              SizedBox(height: AppSpacing.sm),
              Divider(height: 1),
              SizedBox(height: AppSpacing.sm),
              InfoRow(
                label: 'Low',
                value: _formatCurrency(ohlcv['low']),
                valueColor: AppColors.textPrimary,
              ),
              SizedBox(height: AppSpacing.sm),
              Divider(height: 1),
              SizedBox(height: AppSpacing.sm),
              InfoRow(
                label: 'Close',
                value: _formatCurrency(ohlcv['close']),
                valueColor: isPositive ? AppColors.bullish : AppColors.bearish,
              ),
              SizedBox(height: AppSpacing.sm),
              Divider(height: 1),
              SizedBox(height: AppSpacing.sm),
              InfoRow(
                label: 'Volume',
                value: '${(ohlcv['volume'] / 1000000).toStringAsFixed(2)}M',
                valueColor: AppColors.textPrimary,
              ),
              SizedBox(height: AppSpacing.sm),
              Divider(height: 1),
              SizedBox(height: AppSpacing.sm),
              InfoRow(
                label: 'Tanggal Data',
                value: latestData!['date'] ?? '-',
                valueColor: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    final user = authService.currentUser;

    return Drawer(
      child: Container(
        color: AppColors.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: AppColors.primary),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    user?.displayName ?? 'Pengguna',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.home,
              title: 'Beranda',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'Profil',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.history,
              title: 'Riwayat Analisis',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Pengaturan',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            Divider(height: 1),
            _buildDrawerItem(
              icon: Icons.help_outline,
              title: 'Bantuan',
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.info_outline,
              title: 'Tentang',
              onTap: () {},
            ),
            Spacer(),
            Divider(height: 1),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Keluar',
              onTap: _showLogoutDialog,
              textColor: AppColors.error,
              iconColor: AppColors.error,
            ),
            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, size: 24, color: iconColor ?? AppColors.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    );
  }
}


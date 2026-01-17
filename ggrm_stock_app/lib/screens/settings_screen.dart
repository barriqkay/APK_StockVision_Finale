import 'package:flutter/material.dart';
import '../widgets/app_widgets.dart';
import '../theme.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool)? onThemeToggle;
  final bool isDarkMode;

  SettingsScreen({this.onThemeToggle, this.isDarkMode = false});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool notificationsEnabled = true;
  late bool darkModeEnabled;
  bool autoRefreshEnabled = true;
  int refreshInterval = 5;

  @override
  void initState() {
    super.initState();
    darkModeEnabled = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Pengaturan', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            SectionHeader(title: 'Tampilan'),
            SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(
                children: [
                  _buildSwitchItem(
                    icon: Icons.dark_mode,
                    title: 'Mode Gelap',
                    subtitle: 'Aktifkan tema gelap',
                    value: darkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        darkModeEnabled = value;
                      });
                      // Trigger theme change in parent
                      if (widget.onThemeToggle != null) {
                        widget.onThemeToggle!(value);
                      }
                      // Show feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value ? 'Mode Gelap Diaktifkan' : 'Mode Terang Diaktifkan'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1),
                  _buildSwitchItem(
                    icon: Icons.language,
                    title: 'Bahasa',
                    subtitle: 'Indonesia (Default)',
                    value: false,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            // Notifications Section
            SectionHeader(title: 'Notifikasi'),
            SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(
                children: [
                  _buildSwitchItem(
                    icon: Icons.notifications,
                    title: 'Notifikasi Push',
                    subtitle: 'Terima notifikasi prediksi',
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setState(() => notificationsEnabled = value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value ? 'Notifikasi Diaktifkan' : 'Notifikasi Dinonaktifkan'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1),
                  _buildSwitchItem(
                    icon: Icons.autorenew,
                    title: 'Auto Refresh',
                    subtitle: 'Perbarui data otomatis',
                    value: autoRefreshEnabled,
                    onChanged: (value) {
                      setState(() => autoRefreshEnabled = value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value ? 'Auto Refresh Diaktifkan' : 'Auto Refresh Dinonaktifkan'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  if (autoRefreshEnabled) ...[
                    Divider(height: 1),
                    _buildSelectItem(
                      icon: Icons.timer,
                      title: 'Interval Refresh',
                      subtitle: '${refreshInterval} menit',
                      onTap: _showRefreshIntervalDialog,
                    ),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            // Data Section
            SectionHeader(title: 'Data'),
            SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(
                children: [
                  _buildActionItem(
                    icon: Icons.storage,
                    title: 'Cache Data',
                    subtitle: '3.2 MB - Hapus cache untuk mengoptimalkan penyimpanan',
                    onTap: _clearCache,
                  ),
                  Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.download,
                    title: 'Ekspor Data',
                    subtitle: 'Unduh data historis sebagai CSV',
                    onTap: _exportData,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            // About Section
            SectionHeader(title: 'Tentang'),
            SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(
                children: [
                  _buildInfoItem(
                    icon: Icons.info,
                    title: 'Versi Aplikasi',
                    value: '2.0.0',
                  ),
                  Divider(height: 1),
                  _buildInfoItem(
                    icon: Icons.code,
                    title: 'Versi Model ML',
                    value: '1.0.0',
                  ),
                  Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.description,
                    title: 'Syarat & Ketentuan',
                    subtitle: 'Baca kebijakan penggunaan',
                    onTap: _showTerms,
                  ),
                  Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.privacy_tip,
                    title: 'Kebijakan Privasi',
                    subtitle: 'Baca kebijakan privasi',
                    onTap: _showPrivacy,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            // Support Section
            SectionHeader(title: 'Bantuan & Dukungan'),
            SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(
                children: [
                  _buildActionItem(
                    icon: Icons.help_outline,
                    title: 'FAQ',
                    subtitle: 'Pertanyaan yang sering diajukan',
                    onTap: _showFAQ,
                  ),
                  Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.mail_outline,
                    title: 'Hubungi Kami',
                    subtitle: 'support@ggrm-stock.com',
                    onTap: _contactSupport,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.xl),
            
            // Logout Button
            Center(
              child: TextButton(
                onPressed: _showLogoutDialog,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, color: AppColors.error),
                    SizedBox(width: 8),
                    Text(
                      'Keluar dari Akun',
                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: AppSpacing.xl),
            
            // Copyright
            Center(
              child: Text(
                '© ${DateTime.now().year} GGRM Stock Prediction',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
              ),
            ),
            
            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.titleMedium),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: Icon(Icons.chevron_right, color: AppColors.textLight),
    );
  }

  Widget _buildSelectItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.titleMedium),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: Icon(Icons.chevron_right, color: AppColors.textLight),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(title, style: AppTextStyles.titleMedium),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showRefreshIntervalDialog() {
    final intervals = [1, 3, 5, 10, 15, 30];
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pilih Interval', style: AppTextStyles.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: intervals.map((interval) {
            final isSelected = interval == refreshInterval;
            return ListTile(
              title: Text('$interval menit'),
              trailing: isSelected 
                ? Icon(Icons.check, color: AppColors.primary) 
                : null,
              onTap: () {
                setState(() => refreshInterval = interval);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Cache', style: AppTextStyles.titleLarge),
        content: Text('Apakah Anda yakin ingin menghapus cache? Data akan dimuat ulang.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSuccess('Cache berhasil dihapus');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
            ),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    _showSuccess('Fitah sedang dalam pengembangan');
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Syarat & Ketentuan', style: AppTextStyles.titleLarge),
        content: SingleChildScrollView(
          child: Text(
            'Syarat dan Ketentuan Penggunaan\n\n'
            '1. Pendahuluan\n'
            'Aplikasi GGRM Stock Prediction menyediakan prediksi harga saham berdasarkan model machine learning. '
            'Harap dicatat bahwa prediksi ini bukanlah saran keuangan.\n\n'
            '2. Penggunaan\n'
            'Pengguna bertanggung jawab atas keputusan investasi yang diambil berdasarkan informasi dari aplikasi ini.\n\n'
            '3. Batasan Tanggung Jawab\n'
            'Kami tidak bertanggung jawab atas kerugian yang mungkin timbul dari penggunaan aplikasi ini.\n\n'
            '4. Privasi\n'
            'Data pribadi pengguna dijaga kerahasiaannya sesuai dengan kebijakan privasi yang berlaku.',
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
            ),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showPrivacy() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Kebijakan Privasi', style: AppTextStyles.titleLarge),
        content: SingleChildScrollView(
          child: Text(
            'Kebijakan Privasi\n\n'
            'Kami menghormati privasi pengguna dan berkomitmen untuk melindungi data pribadi Anda.\n\n'
            '1. Data yang Dikumpulkan\n'
            '- Informasi akun (nama, email)\n'
            '- Data penggunaan aplikasi\n'
            '- Preferensi pengguna\n\n'
            '2. Penggunaan Data\n'
            'Data digunakan untuk meningkatkan layanan dan pengalaman pengguna.\n\n'
            '3. Keamanan\n'
            'Data disimpan dengan enkripsi yang aman.',
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
            ),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showFAQ() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('FAQ', style: AppTextStyles.titleLarge),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFAQItem(
                'Q: Seberapa akurat prediksi ini?',
                'A: Model ML kami memiliki akurasi tertentu, namun prediksi saham tidak pernah 100% akurat. Gunakan sebagai referensi.',
              ),
              SizedBox(height: AppSpacing.md),
              _buildFAQItem(
                'Q: Bagaimana cara kerja model prediksi?',
                'A: Model menggunakan data historis OHLCV dan indikator teknis untuk memprediksi harga besok.',
              ),
              SizedBox(height: AppSpacing.md),
              _buildFAQItem(
                'Q: Apakah gratis?',
                'A: Ya, aplikasi ini sepenuhnya gratis untuk digunakan.',
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
            ),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: AppTextStyles.titleMedium),
        SizedBox(height: 4),
        Text(answer, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  void _contactSupport() {
    // Open email client
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
            onPressed: () {
              Navigator.pop(ctx);
              // Navigate to login and remove all routes
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 12),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
        margin: EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}


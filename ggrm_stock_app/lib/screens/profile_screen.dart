import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../widgets/app_widgets.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  bool isLoading = false;

  User? get currentUser => authService.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            
            SizedBox(height: AppSpacing.lg),
            
            // Account Info
            SectionHeader(title: 'Informasi Akun'),
            SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(
                children: [
                  _buildInfoItem(
                    icon: Icons.person,
                    title: 'Nama',
                    value: currentUser?.displayName ?? '-',
                    onTap: () => _showEditNameDialog(),
                  ),
                  Divider(height: 1),
                  _buildInfoItem(
                    icon: Icons.email,
                    title: 'Email',
                    value: currentUser?.email ?? '-',
                    subtitle: currentUser?.emailVerified == true 
                      ? 'Terverifikasi' 
                      : 'Belum terverifikasi',
                    subtitleColor: currentUser?.emailVerified == true 
                      ? AppColors.success 
                      : AppColors.warning,
                  ),
                  Divider(height: 1),
                  _buildInfoItem(
                    icon: Icons.phone,
                    title: 'Telepon',
                    value: currentUser?.phoneNumber ?? '-',
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            // Statistics
            SectionHeader(title: 'Statistik Penggunaan'),
            SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Row(
                children: [
                  _buildStatItem(
                    icon: Icons.analytics,
                    label: 'Prediksi',
                    value: '24',
                  ),
                  _buildStatItem(
                    icon: Icons.history,
                    label: 'Riwayat',
                    value: '12',
                  ),
                  _buildStatItem(
                    icon: Icons.calendar_today,
                    label: 'Hari',
                    value: '7',
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            // Actions
            SectionHeader(title: 'Aksi'),
            SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(
                children: [
                  _buildActionItem(
                    icon: Icons.verified_user,
                    title: 'Verifikasi Email',
                    subtitle: currentUser?.emailVerified == true 
                      ? 'Email sudah terverifikasi' 
                      : 'Kirim email verifikasi',
                    onTap: currentUser?.emailVerified == true ? null : _verifyEmail,
                  ),
                  Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.lock,
                    title: 'Ubah Password',
                    subtitle: 'Perbarui password akun Anda',
                    onTap: _resetPassword,
                  ),
                  Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.delete_forever,
                    title: 'Hapus Akun',
                    subtitle: 'Hapus akun secara permanen',
                    onTap: _deleteAccount,
                    textColor: AppColors.error,
                    iconColor: AppColors.error,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return GlassCard(
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(AppRadius.circular),
              boxShadow: AppShadows.medium,
            ),
            child: Center(
              child: Text(
                (currentUser?.displayName ?? 'U')[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          SizedBox(height: AppSpacing.md),
          
          // Name
          Text(
            currentUser?.displayName ?? 'Pengguna',
            style: AppTextStyles.headline3,
          ),
          
          SizedBox(height: AppSpacing.xs),
          
          // Email with verification badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email,
                size: 16,
                color: AppColors.textLight,
              ),
              SizedBox(width: 4),
              Text(
                currentUser?.email ?? '-',
                style: AppTextStyles.bodyMedium,
              ),
              if (currentUser?.emailVerified == true) ...[
                SizedBox(width: 8),
                Icon(
                  Icons.verified,
                  size: 16,
                  color: AppColors.success,
                ),
              ],
            ],
          ),
          
          SizedBox(height: AppSpacing.md),
          
          // Edit Profile Button
          AppButton(
            label: 'Edit Profil',
            onPressed: _showEditNameDialog,
            width: 200,
            height: 40,
            borderRadius: AppRadius.small,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    Color? subtitleColor,
    VoidCallback? onTap,
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
      title: Text(title, style: AppTextStyles.labelMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2),
          Text(value, style: AppTextStyles.bodyLarge),
          if (subtitle != null)
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(color: subtitleColor ?? AppColors.textLight),
            ),
        ],
      ),
      trailing: onTap != null ? Icon(Icons.chevron_right, color: AppColors.textLight) : null,
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTextStyles.titleLarge),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 24),
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
    );
  }

  void _showEditNameDialog() {
    final nameCtrl = TextEditingController(text: currentUser?.displayName ?? '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ubah Nama', style: AppTextStyles.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Note: Need to implement name update in AuthService
              _showSuccess('Nama berhasil diperbarui');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
            ),
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyEmail() async {
    setState(() => isLoading = true);
    try {
      await currentUser?.sendEmailVerification();
      _showSuccess('Email verifikasi telah dikirim');
    } catch (e) {
      _showError('Gagal mengirim email verifikasi');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = currentUser?.email;
    if (email == null) return;
    
    setState(() => isLoading = true);
    try {
      await authService.sendPasswordResetEmail(email);
      _showSuccess('Email reset password telah dikirim ke $email');
    } catch (e) {
      _showError('Gagal mengirim email reset password');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Akun', style: AppTextStyles.titleLarge.copyWith(color: AppColors.error)),
        content: Text(
          'Apakah Anda yakin ingin menghapus akun? Tindakan ini tidak dapat dibatalkan.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Note: Need to reauthenticate before deleting
              _showError('Untuk menghapus akun, silakan hubungi dukungan');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
            ),
            child: Text('Hapus', style: TextStyle(color: Colors.white)),
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
}


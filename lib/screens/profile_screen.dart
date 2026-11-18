import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'edit_profile_screen.dart';
import '../../theme/theme_provider.dart';
import '../../theme/app_theme.dart';
import 'terms_policy_screen.dart';
import 'admin/admin_dashboard.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Pengguna tidak login')),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rawData = snapshot.data?.data();
          final data = rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};

          final displayName = data['fullName']?.toString() ??
              user.displayName ??
              user.email?.split('@').first ??
              'User';
          final displayEmail = data['email']?.toString() ?? user.email ?? '-';
          final role = (data['role']?.toString() ?? 'user').toUpperCase();
          final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                /// ================= PROFILE HEADER CARD =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryLight],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayEmail,
                        style: TextStyle(
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: (role == 'SUPER_ADMIN' || role == 'ADMIN')
                              ? AppTheme.accentBlue.withValues(alpha: 0.15)
                              : AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          role == 'SUPER_ADMIN'
                              ? 'SUPER ADMIN'
                              : (role == 'ADMIN' ? 'ADMINISTRATOR' : 'MEMBER EVENTKU'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: (role == 'SUPER_ADMIN' || role == 'ADMIN') ? AppTheme.accentBlue : AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: user.uid));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text('UID akun disalin ke clipboard!'),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'UID: ${user.uid.length > 12 ? user.uid.substring(0, 12) : user.uid}...',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.copy_rounded,
                                size: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// ================= STATS ROW =================
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('tickets')
                      .where('userId', isEqualTo: user.uid)
                      .snapshots(),
                  builder: (context, ticketSnap) {
                    final ticketCount = ticketSnap.data?.docs.length ?? 0;

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statTile('Tiket Terdaftar', ticketCount.toString(), isDark),
                          Container(
                            height: 30,
                            width: 1,
                            color: isDark ? Colors.white12 : Colors.grey.shade200,
                          ),
                          _statTile('Status Akun', 'Terverifikasi', isDark),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                /// ================= SETTINGS GROUP =================
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      _settingTile(
                        icon: Icons.edit_note_rounded,
                        iconColor: AppTheme.accentBlue,
                        title: 'Edit Profil',
                        subtitle: 'Ubah nama lengkap dan kota asal',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
                        },
                        isDark: isDark,
                      ),
                      const Divider(height: 1, indent: 64),
                      _settingTile(
                        icon: Icons.dark_mode_rounded,
                        iconColor: AppTheme.accentPurple,
                        title: 'Mode Gelap (Dark Mode)',
                        subtitle: 'Sesuaikan kenyamanan tampilan',
                        trailing: Switch(
                          value: theme.isDark,
                          activeThumbColor: AppTheme.primary,
                          onChanged: theme.toggleTheme,
                        ),
                        onTap: () => theme.toggleTheme(!theme.isDark),
                        isDark: isDark,
                      ),
                      const Divider(height: 1, indent: 64),
                      _settingTile(
                        icon: Icons.help_outline_rounded,
                        iconColor: AppTheme.primaryLight,
                        title: 'Pusat Bantuan & FAQ',
                        subtitle: 'Pertanyaan seputar tiket & event',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: const Row(
                                children: [
                                  Icon(Icons.help_outline_rounded, color: AppTheme.primary),
                                  SizedBox(width: 8),
                                  Text('Bantuan EventKu'),
                                ],
                              ),
                              content: const SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Bagaimana cara masuk ke venue event?',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Buka menu My Tickets, ketuk tiket aktif kamu, lalu tunjukkan Boarding Pass QR kepada panitia di meja registrasi.',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    SizedBox(height: 14),
                                    Text(
                                      'Apakah tiket bisa dibatalkan?',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Ya, kamu dapat menekan tombol "Batalkan" di tiket aktif kamu agar kuota dapat digunakan oleh peserta lain.',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    SizedBox(height: 14),
                                    Text(
                                      'Kapan E-Sertifikat diterbitkan?',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'E-Sertifikat akan dikirimkan ke email terdaftar maksimal 1x24 jam setelah status tiketmu terverifikasi hadir (Completed).',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Mengerti', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        isDark: isDark,
                      ),
                      const Divider(height: 1, indent: 64),
                      _settingTile(
                        icon: Icons.policy_rounded,
                        iconColor: AppTheme.success,
                        title: 'Syarat & Kebijakan Privasi',
                        subtitle: 'Ketentuan layanan EventKu',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TermsPolicyScreen()),
                          );
                        },
                        isDark: isDark,
                      ),
                      if (role == 'ADMIN' || role == 'SUPER_ADMIN') ...[
                        const Divider(height: 1, indent: 64),
                        _settingTile(
                          icon: Icons.admin_panel_settings_rounded,
                          iconColor: AppTheme.primary,
                          title: 'Admin Dashboard',
                          subtitle: 'Buka panel kelola event & gate check-in',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminDashboard()),
                            );
                          },
                          isDark: isDark,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                /// ================= LOGOUT BUTTON =================
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.danger),
                    label: const Text(
                      'Keluar dari Akun',
                      style: TextStyle(
                        color: AppTheme.danger,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.3)),
                      backgroundColor: AppTheme.danger.withValues(alpha: 0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Konfirmasi Logout'),
                          content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.danger,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Logout', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      }
                    },
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statTile(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
          ),
        ),
      ],
    );
  }

  Widget _settingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isDark ? Colors.white : AppTheme.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
        ),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
      onTap: onTap,
    );
  }
}

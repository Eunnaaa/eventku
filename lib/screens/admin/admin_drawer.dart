import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'manage_event_screen.dart';
import 'manage_user_screen.dart';
import 'analytics_screen.dart';
import 'check_in_screen.dart';
import '../home_screen.dart';
import '../../services/event_seed_service.dart';
import '../../theme/admin_colors.dart';
import '../../theme/app_theme.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryLight],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.shield_rounded, color: AppTheme.primary, size: 28),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Super Admin',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'EventKu Management',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _item(context, Icons.dashboard_rounded, 'Dashboard', () {
            Navigator.pop(context);
          }),

          _item(context, Icons.qr_code_scanner_rounded, 'Check-in Peserta', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CheckInScreen()),
            );
          }),

          _item(context, Icons.event_available_rounded, 'Manage Events', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageEventScreen()),
            );
          }),

          _item(context, Icons.people_alt_rounded, 'Manage Users', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageUserScreen()),
            );
          }),

          _item(context, Icons.insights_rounded, 'App Analytics', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
            );
          }),

          _item(context, Icons.smartphone_rounded, 'Tampilan Peserta', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }),

          _item(context, Icons.auto_awesome_rounded, 'Seed Data Acara', () async {
            Navigator.pop(context);
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Expanded(child: Text('Muat Event Sampel?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
                  ],
                ),
                content: const Text(
                  'Sistem akan menambahkan event berkualitas tinggi untuk kategori Technology, Business, Health, Travel, dan Education.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Muat Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );

            if (confirm == true && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Sedang menambahkan event sampel...'),
                ),
              );

              try {
                final count = await EventSeedService.seedAllCategories();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.success,
                      content: Text('Berhasil memuat $count event baru!'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.danger,
                      content: Text('Gagal memuat event: $e'),
                    ),
                  );
                }
              }
            }
          }),

          const Spacer(),

          const Divider(indent: 20, endIndent: 20),

          _item(context, Icons.logout_rounded, 'Logout Admin', () async {
            Navigator.pop(context);
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('Logout Super Admin'),
                content: const Text('Apakah Anda yakin ingin keluar dari sesi admin?'),
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
            }
          }, isDestructive: true),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.danger : AdminColors.textDark,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.danger : AdminColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}

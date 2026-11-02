import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TermsPolicyScreen extends StatelessWidget {
  const TermsPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Ketentuan & Kebijakan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _policyCard(
              title: 'Ketentuan Layanan (Terms of Service)',
              icon: Icons.gavel_rounded,
              color: AppTheme.primary,
              isDark: isDark,
              content:
                  'Dengan menggunakan aplikasi EventKu, Anda setuju untuk mematuhi semua hukum dan peraturan yang berlaku serta tidak menyalahgunakan platform untuk tujuan ilegal atau manipulasi kuota tiket.',
            ),
            const SizedBox(height: 16),
            _policyCard(
              title: 'Kebijakan Privasi (Privacy Policy)',
              icon: Icons.security_rounded,
              color: AppTheme.accentBlue,
              isDark: isDark,
              content:
                  'Informasi pribadi Anda seperti nama lengkap, alamat email, dan asal domisili disimpan secara aman dan hanya digunakan untuk kepentingan fungsionalitas pemesanan tiket, penerbitan boarding pass, dan pengiriman e-sertifikat.',
            ),
            const SizedBox(height: 16),
            _policyCard(
              title: 'Kontak & Dukungan',
              icon: Icons.support_agent_rounded,
              color: AppTheme.success,
              isDark: isDark,
              content:
                  'Jika Anda memiliki pertanyaan, keluhan, atau membutuhkan bantuan terkait tiket dan akun Anda, silakan hubungi tim kami melalui email resmi support@eventku.app.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _policyCard({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.border(isDark),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              height: 1.6,
              fontSize: 13,
              color: AppTheme.textMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

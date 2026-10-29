import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// LOGO
            Image.asset(
              'assets/images/logo1.png',
              height: 90,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.event_seat_rounded,
                size: 70,
                color: AppTheme.primary,
              ),
            ),

            const SizedBox(height: 28),

            /// LOADING INDICATOR
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppTheme.primary,
              ),
            ),

            const SizedBox(height: 16),

            /// TEXT
            const Text(
              'Memuat EventKu...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

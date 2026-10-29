import 'package:flutter/material.dart';
import '../../theme/admin_colors.dart';
import '../../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyData = [14, 22, 18, 30, 26, 20, 16];
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final maxValue = weeklyData.reduce((a, b) => a > b ? a : b);
    final totalActivity = weeklyData.reduce((a, b) => a + b);
    final avgDaily = (totalActivity / weeklyData.length).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('App Analytics'),
        backgroundColor: Colors.transparent,
        foregroundColor: AdminColors.textDark,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE & SUBTITLE
            const Text(
              'Aktivitas Pengguna Mingguan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AdminColors.textDark,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ringkasan interaksi dan pemesanan tiket 7 hari terakhir',
              style: TextStyle(
                color: AdminColors.textGrey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            /// QUICK STAT TILES
            Row(
              children: [
                Expanded(
                  child: _metricTile(
                    'Total Interaksi',
                    totalActivity.toString(),
                    Icons.trending_up_rounded,
                    AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _metricTile(
                    'Rata-rata / Hari',
                    avgDaily,
                    Icons.show_chart_rounded,
                    AppTheme.accentBlue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// CARD CONTAINER BAR CHART
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminColors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grafik Pemesanan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AdminColors.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '7 Hari Terakhir',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  /// BAR CHART
                  SizedBox(
                    height: 180,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(weeklyData.length, (index) {
                        final value = weeklyData[index];
                        final heightFactor = value / maxValue;
                        final isPeak = value == maxValue;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              value.toString(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isPeak ? FontWeight.bold : FontWeight.w500,
                                color: isPeak ? AppTheme.primary : AdminColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 22,
                              height: 125 * heightFactor,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isPeak
                                      ? [AppTheme.primary, AppTheme.primaryLight]
                                      : [const Color(0xFF94A3B8), const Color(0xFFCBD5E1)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              days[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isPeak ? FontWeight.bold : FontWeight.w600,
                                color: isPeak ? AdminColors.textDark : AdminColors.textGrey,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// INFO BANNER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline_rounded, color: AdminColors.textGrey, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Puncak kunjungan tertinggi berada di hari Kamis dengan 30 aktivitas booking tiket.',
                      style: TextStyle(
                        color: AdminColors.textDark,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AdminColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AdminColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

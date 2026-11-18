import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/admin_colors.dart';
import '../../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    const dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    // 7 hari terakhir (dari 6 hari lalu sampai hari ini)
    final List<DateTime> pastDays = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });

    final List<String> days = pastDays.map((d) => dayNames[d.weekday % 7]).toList();
    final startTimestamp = Timestamp.fromDate(pastDays.first);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('App Analytics'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AdminColors.textDark,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('createdAt', isGreaterThanOrEqualTo: startTimestamp)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 54, color: AppTheme.danger),
                    const SizedBox(height: 14),
                    Text(
                      'Gagal Memuat Data Analitik',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AdminColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pastikan akun memiliki hak akses Super Admin atau periksa koneksi internet: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final List<int> weeklyData = List.filled(7, 0);

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final rawCreated = data['createdAt'];
            if (rawCreated is Timestamp) {
              final dt = rawCreated.toDate();
              final ticketDate = DateTime(dt.year, dt.month, dt.day);
              for (int i = 0; i < pastDays.length; i++) {
                if (pastDays[i] == ticketDate) {
                  weeklyData[i]++;
                  break;
                }
              }
            }
          }

          final rawMax = weeklyData.reduce((a, b) => a > b ? a : b);
          final maxValue = rawMax > 0 ? rawMax : 1;
          final totalActivity = weeklyData.reduce((a, b) => a + b);
          final avgDaily = (totalActivity / weeklyData.length).toStringAsFixed(1);

          int peakIndex = 0;
          for (int i = 1; i < weeklyData.length; i++) {
            if (weeklyData[i] > weeklyData[peakIndex]) {
              peakIndex = i;
            }
          }
          final peakDay = days[peakIndex];
          final peakCount = weeklyData[peakIndex];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE & SUBTITLE
                Text(
                  'Aktivitas Pengguna Mingguan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AdminColors.textDark,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ringkasan interaksi dan pemesanan tiket 7 hari terakhir',
                  style: TextStyle(
                    color: isDark ? AppTheme.textMutedDark : AdminColors.textGrey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 20),

                /// QUICK STAT TILES
                Row(
                  children: [
                    Expanded(
                      child: _metricTile(
                        'Pemesanan 7 Hari',
                        totalActivity.toString(),
                        Icons.trending_up_rounded,
                        AppTheme.primary,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _metricTile(
                        'Rata-rata / Hari',
                        avgDaily,
                        Icons.show_chart_rounded,
                        AppTheme.accentBlue,
                        isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// CARD CONTAINER BAR CHART
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.border(isDark)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
                          Text(
                            'Grafik Pemesanan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AdminColors.textDark,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Realtime 7 Hari',
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
                            final heightFactor = rawMax > 0 ? (value / maxValue) : 0.05;
                            final isPeak = rawMax > 0 && value == rawMax;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  value.toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isPeak ? FontWeight.bold : FontWeight.w500,
                                    color: isPeak ? AppTheme.primary : (isDark ? AppTheme.textMutedDark : AdminColors.textGrey),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 22,
                                  height: (125 * heightFactor).clamp(6.0, 125.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isPeak
                                          ? [AppTheme.primary, AppTheme.primaryLight]
                                          : [
                                              isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8),
                                              isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                                            ],
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
                                    color: isPeak
                                        ? AppTheme.primary
                                        : (isDark ? AppTheme.textMutedDark : AdminColors.textGrey),
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
                    color: isDark ? AppTheme.surfaceDark : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border(isDark)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: isDark ? AppTheme.primaryLight : AdminColors.textGrey, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          peakCount > 0
                              ? 'Puncak pemesanan 7 hari terakhir berada di hari $peakDay dengan $peakCount tiket berhasil dipesan.'
                              : 'Belum ada aktivitas pemesanan tiket dalam 7 hari terakhir.',
                          style: TextStyle(
                            color: isDark ? Colors.white : AdminColors.textDark,
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
          );
        },
      ),
    );
  }

  Widget _metricTile(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AdminColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.textMutedDark : AdminColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

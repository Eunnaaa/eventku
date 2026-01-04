import 'package:flutter/material.dart';
import '../../theme/admin_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyData = [14, 22, 18, 30, 26, 20, 16];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxValue = weeklyData.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('App Analytics'),
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            const Text(
              'Weekly App Activity',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AdminColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Overview of application usage in the last 7 days',
              style: TextStyle(
                color: AdminColors.textGrey,
              ),
            ),

            const SizedBox(height: 30),

            /// CARD CONTAINER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminColors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  /// BAR CHART
                  SizedBox(
                    height: 180,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(weeklyData.length, (index) {
                        final value = weeklyData[index];
                        final heightFactor = value / maxValue;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              value.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AdminColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 18,
                              height: 130 * heightFactor,
                              decoration: BoxDecoration(
                                color: AdminColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              days[index],
                              style: const TextStyle(
                                fontSize: 12,
                                color: AdminColors.textGrey,
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

            const SizedBox(height: 30),

            /// INFO
            const Text(
              'This chart represents how active users interact with the application each day.',
              style: TextStyle(
                color: AdminColors.textGrey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

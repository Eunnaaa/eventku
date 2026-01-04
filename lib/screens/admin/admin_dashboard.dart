import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_drawer.dart';
import 'manage_event_screen.dart';
import 'manage_user_screen.dart';
import 'analytics_screen.dart';
import '../../theme/admin_colors.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            /// EVENTS
            _card(
              context,
              icon: Icons.event,
              title: 'Events',
              collection: 'events',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageEventScreen(),
                ),
              ),
            ),

            /// TICKETS
            _card(
              context,
              icon: Icons.confirmation_number,
              title: 'Tickets',
              collection: 'tickets',
              onTap: () {},
            ),

            /// USERS
            _card(
              context,
              icon: Icons.people,
              title: 'Users',
              collection: 'users',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageUserScreen(),
                ),
              ),
            ),

            /// 🔥 ANALYTICS (PENGGANTI BOOKMARK)
            _analyticsCard(context),
          ],
        ),
      ),
    );
  }

  /// ===================== STANDARD CARD =====================
  Widget _card(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String collection,
        required VoidCallback onTap,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AdminColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection(collection).snapshots(),
          builder: (context, snapshot) {
            final count =
            snapshot.hasData ? snapshot.data!.docs.length : 0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 42, color: AdminColors.primary),
                const SizedBox(height: 12),
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(color: AdminColors.textGrey),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// ===================== ANALYTICS CARD =====================
  Widget _analyticsCard(BuildContext context) {
    final weeklyData = [12, 18, 14, 22, 19, 16, 13];
    final maxValue = weeklyData.reduce((a, b) => a > b ? a : b);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AnalyticsScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AdminColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🔥 VISUAL AREA (SAMA DENGAN ICON)
            SizedBox(
              height: 42,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weeklyData.map((value) {
                  final heightFactor = value / maxValue;
                  return Container(
                    width: 6,
                    height: 42 * heightFactor,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AdminColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              '-',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AdminColors.textDark,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Weekly activity',
              style: TextStyle(color: AdminColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}

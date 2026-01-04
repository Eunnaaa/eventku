// lib/screens/admin/admin_drawer.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'manage_event_screen.dart';
import 'manage_user_screen.dart';
import '../../theme/admin_colors.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            width: double.infinity,
            color: AdminColors.primary,
            child: Row(
              children: const [
                CircleAvatar(radius: 26, backgroundColor: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Super Admin',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),

          _item(context, Icons.dashboard, 'Dashboard', () {
            Navigator.pop(context);
          }),

          _item(context, Icons.event, 'Manage Events', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageEventScreen()),
            );
          }),

          _item(context, Icons.people, 'Manage Users', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageUserScreen()),
            );
          }),

          const Spacer(),

          _item(context, Icons.logout, 'Logout', () async {
            await FirebaseAuth.instance.signOut();
          }),
        ],
      ),
    );
  }

  Widget _item(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(icon, color: AdminColors.primary),
      title: Text(title),
      onTap: onTap,
    );
  }
}

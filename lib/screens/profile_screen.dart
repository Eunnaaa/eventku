import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'edit_profile_screen.dart';
import '../../theme/theme_provider.dart';
import 'terms_policy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// AVATAR
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                ),

                const SizedBox(height: 16),

                /// NAME
                Text(
                  data['fullName'] ?? '-',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                /// EMAIL
                Text(
                  data['email'],
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                /// EDIT PROFILE
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),

                /// DARK MODE
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: theme.isDark,
                    onChanged: theme.toggleTheme,
                  ),
                ),

                /// LANGUAGE

                /// TERMS
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms & Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsPolicyScreen(),
                      ),
                    );
                  },
                ),

                const Divider(),

                /// LOGOUT
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.black),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF914D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

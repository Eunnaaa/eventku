import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:eventku/screens/guest_landing_screen.dart';
import 'package:eventku/screens/home_screen.dart';
import 'package:eventku/screens/admin/admin_dashboard.dart';
import 'package:eventku/screens/loading_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {

        /// 1. Loading auth
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        /// 2. Guest (belum login)
        if (!authSnapshot.hasData) {
          return const GuestLandingScreen();
        }

        final uid = authSnapshot.data!.uid;

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (context, userSnapshot) {

            /// 3. Loading Firestore
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }

            /// 4. Error / user doc tidak ada -> fallback user
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const HomePage();
            }

            final data = userSnapshot.data!.data()!;
            final role = data['role'] ?? 'user';

            /// ADMIN / SUPER ADMIN
            if (role == 'super_admin' || role == 'admin') {
              return const AdminDashboard();
            }

            /// USER BIASA
            return const HomePage();
          },
        );
      },
    );
  }
}

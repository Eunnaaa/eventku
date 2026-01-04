import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageUserScreen extends StatelessWidget {
  const ManageUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Manage Users'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {

          /// 🔴 ERROR HANDLING (PENTING)
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Firestore Error:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final userData = userDoc.data() as Map<String, dynamic>;

              return _userCard(userDoc.id, userData);
            },
          );
        },
      ),
    );
  }

  /// ================= USER CARD =================
  Widget _userCard(String userId, Map<String, dynamic> userData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// USER INFO
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['fullName'] ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      userData['email'] ?? '-',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              _roleBadge(userData['role'] ?? 'user'),
            ],
          ),

          const SizedBox(height: 16),

          /// USER TICKETS
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tickets')
                .where('userId', isEqualTo: userId)
                .snapshots(),
            builder: (context, ticketSnapshot) {

              if (ticketSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const LinearProgressIndicator();
              }

              final tickets = ticketSnapshot.data?.docs ?? [];

              if (tickets.isEmpty) {
                return const Text(
                  'No booked events',
                  style: TextStyle(color: Colors.grey),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booked Events (${tickets.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ...tickets.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${data['date']} • ${data['time']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            data['location'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// ================= ROLE BADGE =================
  Widget _roleBadge(String role) {
    final isAdmin = role == 'admin';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.blue.withOpacity(0.15) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isAdmin ? Colors.blue : Colors.black54,
          fontSize: 12,
        ),
      ),
    );
  }
}

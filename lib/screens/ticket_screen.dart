import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text(
          'My Tickets',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF914D),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ticketList(user!.uid, 'upcoming'),
          _ticketList(user.uid, 'completed'),
        ],
      ),
    );
  }

  /// ================= TICKET LIST =================
  Widget _ticketList(String uid, String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tickets')
          .where('userId', isEqualTo: uid)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyState(status);
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  /// ICON (GANTI IMAGE)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF914D).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.confirmation_number_outlined,
                      size: 30,
                      color: Color(0xFFFF914D),
                    ),
                  ),

                  const SizedBox(width: 14),

                  /// CONTENT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] ?? '-',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${data['date']} • ${data['time']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data['location'] ?? '-',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  /// STATUS
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: status == 'upcoming'
                          ? const Color(0xFFFFF3CD)
                          : const Color(0xFFE6F4EA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status == 'upcoming' ? 'Upcoming' : 'Completed',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: status == 'upcoming'
                            ? const Color(0xFF856404)
                            : const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// ================= EMPTY STATE =================
  Widget _emptyState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            status == 'upcoming'
                ? 'No Upcoming Tickets'
                : 'No Completed Tickets',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Book an event and your ticket\nwill appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

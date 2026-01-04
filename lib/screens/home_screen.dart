import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';
import '../widgets/event_card.dart';
import 'ticket_screen.dart';
import 'event_list_screen.dart';
import 'profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String selectedCategory = 'All';

  final categories = ['All', 'Health', 'Business', 'Travel'];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final pages = [
      _homeContent(user),
      const TicketScreen(),
      const EventListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFFFF914D),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined), label: 'Ticket'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined), label: 'Events'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  // ================= HOME CONTENT =================
  Widget _homeContent(User? user) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= HEADER =================
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
                ),
                const SizedBox(width: 12),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.data();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data?['fullName'] ??
                              user.email!.split('@').first,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          data?['country'] ?? '-',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 26),

            /// ================= HEADLINE =================
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  height: 1.2,
                ),
                children: [
                  TextSpan(text: 'MAKE YOUR '),
                  TextSpan(
                    text: 'PARTY PLANS ',
                    style: TextStyle(color: Color(0xFFFF914D)),
                  ),
                  TextSpan(text: 'OUT HERE'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ================= UPCOMING TITLE =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Upcoming Events',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'See All',
                  style: TextStyle(
                      color: Color(0xFFFF914D),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ================= CATEGORY =================
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final active = categories[i] == selectedCategory;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => selectedCategory = categories[i]),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFFFF914D)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        categories[i],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                          active ? Colors.black : Colors.black54,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// ================= EVENT CARD AREA =================
            /// (TIDAK DIUBAH – KAMU SUDAH PUNYA)
            SizedBox(
              height: 260,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .where('isPublished', isEqualTo: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Failed to load events',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final events = snapshot.data!.docs
                      .map((e) => EventModel.fromFirestore(e))
                      .toList();

                  if (events.isEmpty) {
                    return const Center(child: Text('No upcoming events'));
                  }

                  /// 🔥 SORT CLIENT SIDE (NO INDEX)
                  events.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: events.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: EventCard(event: events[i]),
                      );
                    },
                  );
                },
              ),
            ),


            const SizedBox(height: 24),

            /// ================= DASHED DIVIDER =================
            Row(
              children: List.generate(
                40,
                    (i) => Expanded(
                  child: Container(
                    height: 1,
                    color: i.isEven
                        ? Colors.grey.shade300
                        : Colors.transparent,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ================= POPULAR EVENTS =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Popular Events',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'See All',
                  style: TextStyle(
                      color: Color(0xFFFF914D),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ================= POPULAR CARD AREA =================
            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  SizedBox(width: 260),
                  SizedBox(width: 16),
                  SizedBox(width: 260),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

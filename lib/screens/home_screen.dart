import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';
import '../widgets/event_card.dart';
import '../theme/app_theme.dart';
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

  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Technology', 'icon': Icons.terminal_rounded},
    {'name': 'Business', 'icon': Icons.trending_up_rounded},
    {'name': 'Health', 'icon': Icons.health_and_safety_rounded},
    {'name': 'Travel', 'icon': Icons.explore_rounded},
    {'name': 'Education', 'icon': Icons.school_rounded},
  ];

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 17) return 'Selamat Siang';
    return 'Selamat Malam';
  }

  IconData _greetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_cloudy_rounded;
    return Icons.nights_stay_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      _homeContent(user, isDark),
      const TicketScreen(),
      const EventListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppTheme.primary,
              unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.confirmation_number_outlined),
                  activeIcon: Icon(Icons.confirmation_number_rounded),
                  label: 'My Ticket',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore_rounded),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HOME CONTENT =================
  Widget _homeContent(User? user, bool isDark) {
    if (user == null) {
      return const Center(child: Text('Silakan login'));
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= HEADER WITH USER PROFILE =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.data();
                    final defaultName = user.email != null && user.email!.contains('@')
                        ? user.email!.split('@').first
                        : 'Friend';
                    final fullName = data?['fullName']?.toString() ?? defaultName;
                    final country = data?['country']?.toString() ?? 'Indonesia';
                    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primaryLight],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _greetingIcon(),
                                  size: 13,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _greeting(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                                if (country.isNotEmpty) ...[
                                  Text(
                                    ' • $country',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              fullName,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: isDark ? Colors.white : AppTheme.textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 2),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: isDark ? Colors.white : AppTheme.textDark,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ================= ACTIVE TICKET GLANCE =================
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tickets')
                  .where('userId', isEqualTo: user.uid)
                  .where('status', isEqualTo: 'upcoming')
                  .limit(1)
                  .snapshots(),
              builder: (context, ticketSnap) {
                if (!ticketSnap.hasData || ticketSnap.data!.docs.isEmpty) {
                  return const SizedBox();
                }
                final nextTicket = ticketSnap.data!.docs.first.data() as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tiket Aktif Mendatang',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              nextTicket['title']?.toString() ?? 'Event',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => setState(() => _currentIndex = 1),
                        child: const Text(
                          'Lihat Pass',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            /// ================= HERO BANNER CARD =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E2638), Color(0xFF111520)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -15,
                    child: Icon(
                      Icons.celebration_rounded,
                      size: 110,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: AppTheme.primaryLight, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'FEATURED EVENTS',
                              style: TextStyle(
                                color: AppTheme.primaryLight,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Jelajahi Workshop &\nSeminar Favoritmu',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Temukan tiket dan amankan kursimu sekarang.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// ================= CATEGORY ROW =================
            Text(
              'Kategori Event',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.textDark,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final name = cat['name'] as String;
                  final icon = cat['icon'] as IconData;
                  final active = name == selectedCategory;

                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = name),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: active
                            ? const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryLight],
                              )
                            : null,
                        color: active
                            ? null
                            : (isDark ? AppTheme.cardDark : Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: active
                              ? Colors.transparent
                              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                        ),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            size: 16,
                            color: active
                                ? Colors.white
                                : (isDark ? Colors.white70 : const Color(0xFF475569)),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: active
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : const Color(0xFF475569)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            /// ================= UPCOMING TITLE =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 2),
                  child: const Row(
                    children: [
                      Text(
                        'See All',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.primary),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ================= EVENT CARD AREA =================
            SizedBox(
              height: 280,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .where('isPublished', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Gagal memuat event',
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var events = snapshot.data!.docs
                      .map((e) => EventModel.fromFirestore(e))
                      .toList();

                  // Sort by upcoming event date
                  events.sort((a, b) => a.eventDate.compareTo(b.eventDate));

                  // Filter by category
                  if (selectedCategory != 'All') {
                    events = events
                        .where((e) =>
                            e.category.toLowerCase() ==
                            selectedCategory.toLowerCase())
                        .toList();
                  }

                  if (events.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy_rounded, size: 44, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            selectedCategory == 'All'
                                ? 'Belum ada event mendatang'
                                : 'Tidak ada event di kategori $selectedCategory',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  events.sort((a, b) => a.eventDate.compareTo(b.eventDate));

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: events.length,
                    itemBuilder: (context, i) {
                      return EventCard(event: events[i], width: 275);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            /// ================= POPULAR EVENTS =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 2),
                  child: const Row(
                    children: [
                      Text(
                        'See All',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.primary),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 280,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .where('isPublished', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SizedBox();
                  }

                  final popularEvents = snapshot.data!.docs
                      .map((e) => EventModel.fromFirestore(e))
                      .toList();

                  popularEvents.sort((a, b) => b.bookedCount.compareTo(a.bookedCount));

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: popularEvents.length,
                    itemBuilder: (context, i) {
                      return EventCard(
                        event: popularEvents[i],
                        width: 260,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';
import '../widgets/event_card.dart';
import '../theme/app_theme.dart';
import '../services/event_seed_service.dart';
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
  bool _isSeeding = false;

  Future<void> _handleSeedUpcoming() async {
    if (_isSeeding) return;
    setState(() => _isSeeding = true);

    try {
      final added = await EventSeedService.seedAllCategories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            content: Text(
              added > 0
                  ? 'Berhasil memuat $added event mendatang baru ke database!'
                  : 'Semua event sampel sudah tersinkronisasi.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final err = e.toString();
        if (err.contains('permission-denied')) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.shield_rounded, color: AppTheme.danger),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Akses Khusus Admin', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              content: const Text(
                'Akun Anda saat ini memiliki role "user" (peserta biasa), sedangkan aturan keamanan Firestore (Security Rules) membatasi penulisan event baru hanya untuk role "super_admin" atau "admin".\n\n'
                'Untuk mengaktifkan akses Super Admin akun Anda:\n'
                '1. Buka Firebase Console (project: eventku-s)\n'
                '2. Masuk ke Firestore Database > koleksi users\n'
                '3. Ubah field "role" akun Anda dari "user" menjadi "super_admin".',
                style: TextStyle(fontSize: 13, height: 1.45),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Mengerti', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.danger,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              content: Text('Gagal menyinkronkan event: $e'),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSeeding = false);
      }
    }
  }

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
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
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
              unselectedItemColor: AppTheme.textMuted(isDark),
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
                                    color: AppTheme.textMuted(isDark),
                                  ),
                                ),
                                if (country.isNotEmpty) ...[
                                  Text(
                                    ' • $country',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white54 : AppTheme.textMutedLight,
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
                              : AppTheme.border(isDark),
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
                                : (isDark ? Colors.white70 : AppTheme.textMutedLight),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: active
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : AppTheme.textMutedLight),
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

            /// ================= CONSOLIDATED REAL-TIME EVENT STREAMS =================
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .where('isPublished', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Text(
                      'Gagal memuat event',
                      style: TextStyle(color: Colors.red.shade400),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 280,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final allEvents = (snapshot.data?.docs ?? [])
                    .map((e) => EventModel.fromFirestore(e))
                    .toList();

                final now = DateTime.now();
                final todayStart = DateTime(now.year, now.month, now.day);

                // 1. Upcoming Events list (acara hari ini hingga masa mendatang)
                var upcomingEvents = allEvents.where((e) {
                  final dt = e.eventDate.toDate();
                  final endOfDay = DateTime(dt.year, dt.month, dt.day, 23, 59, 59);
                  return endOfDay.isAfter(todayStart);
                }).toList();
                upcomingEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));

                if (selectedCategory != 'All') {
                  upcomingEvents = upcomingEvents
                      .where((e) =>
                          e.category.toLowerCase() ==
                          selectedCategory.toLowerCase())
                      .toList();
                }

                // 2. Popular Events list
                final popularEvents = List<EventModel>.from(allEvents);
                popularEvents.sort((a, b) => b.bookedCount.compareTo(a.bookedCount));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// UPCOMING EVENTS CAROUSEL
                    SizedBox(
                      height: 280,
                      child: upcomingEvents.isEmpty
                          ? Container(
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
                                  const SizedBox(height: 14),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: _isSeeding ? null : _handleSeedUpcoming,
                                    icon: _isSeeding
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : const Icon(Icons.auto_awesome_rounded, size: 16),
                                    label: Text(
                                      _isSeeding ? 'Memuat Data...' : 'Muat Event Sampel',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: upcomingEvents.length,
                              itemBuilder: (context, i) {
                                return EventCard(event: upcomingEvents[i], width: 275);
                              },
                            ),
                    ),

                    const SizedBox(height: 32),

                    /// POPULAR EVENTS HEADER
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

                    /// POPULAR EVENTS CAROUSEL
                    SizedBox(
                      height: 280,
                      child: popularEvents.isEmpty
                          ? const SizedBox()
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: popularEvents.length,
                              itemBuilder: (context, i) {
                                return EventCard(
                                  event: popularEvents[i],
                                  width: 260,
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

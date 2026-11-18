import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';
import '../theme/app_theme.dart';
import '../services/event_seed_service.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final _searchController = TextEditingController();
  String search = '';
  String selectedCategory = 'All';
  String selectedType = 'All'; // 'All', 'Online', 'Offline'
  bool isSeeding = false;

  final List<Map<String, dynamic>> categories = const [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Technology', 'icon': Icons.terminal_rounded},
    {'name': 'Business', 'icon': Icons.trending_up_rounded},
    {'name': 'Health', 'icon': Icons.health_and_safety_rounded},
    {'name': 'Travel', 'icon': Icons.explore_rounded},
    {'name': 'Education', 'icon': Icons.school_rounded},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      search = '';
      selectedCategory = 'All';
      selectedType = 'All';
    });
  }

  Future<void> _handleSeedUpcoming() async {
    if (isSeeding) return;
    setState(() => isSeeding = true);

    try {
      final added = await EventSeedService.seedAllCategories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            content: Text(
              added > 0
                  ? 'Berhasil memasukkan $added event mendatang baru ke database!'
                  : 'Semua event mendatang sampel sudah tersinkronisasi.',
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
        setState(() => isSeeding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasActiveFilter = search.isNotEmpty || selectedCategory != 'All' || selectedType != 'All';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Explore Events'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: isSeeding
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                  )
                : const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary),
            tooltip: 'Sinkronkan Event Sampel',
            onPressed: isSeeding ? null : _handleSeedUpcoming,
          ),
        ],
      ),
      body: Column(
        children: [
          /// ================= 1. SEARCH BAR =================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => search = v.trim().toLowerCase()),
                style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari event, pembicara, topik, kota...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 22),
                  suffixIcon: search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => search = '');
                          },
                        )
                      : null,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),

          /// ================= 2. FORMAT SEGMENTED CONTROL =================
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              ),
            ),
            child: Row(
              children: [
                _formatSegment('Semua Format', 'All', Icons.grid_view_rounded, isDark),
                _formatSegment('Online', 'Online', Icons.laptop_chromebook_rounded, isDark),
                _formatSegment('Offline Venue', 'Offline', Icons.place_rounded, isDark),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// ================= 3. CATEGORY HORIZONTAL PILLS =================
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final cat = categories[i];
                final name = cat['name'] as String;
                final icon = cat['icon'] as IconData;
                final active = name == selectedCategory;

                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = name),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: active
                          ? const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primaryLight],
                            )
                          : null,
                      color: active
                          ? null
                          : (isDark ? AppTheme.cardDark : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: active
                            ? Colors.transparent
                            : AppTheme.border(isDark),
                      ),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 14,
                          color: active
                              ? Colors.white
                              : (isDark ? Colors.white70 : AppTheme.textMutedLight),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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

          /// ================= 4. RESULTS STREAM & LIST =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .where('isPublished', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Terjadi kesalahan memuat event',
                      style: TextStyle(color: AppTheme.danger),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var events = (snapshot.data?.docs ?? [])
                    .map((e) => EventModel.fromFirestore(e))
                    .where((e) {
                      if (search.isEmpty) return true;
                      final q = search;
                      return e.title.toLowerCase().contains(q) ||
                          e.speakerName.toLowerCase().contains(q) ||
                          e.location.toLowerCase().contains(q) ||
                          e.category.toLowerCase().contains(q) ||
                          e.description.toLowerCase().contains(q);
                    })
                    .toList();

                if (selectedCategory != 'All') {
                  events = events
                      .where((e) =>
                          e.category.toLowerCase() ==
                          selectedCategory.toLowerCase())
                      .toList();
                }

                if (selectedType == 'Online') {
                  events = events.where((e) => e.isOnline).toList();
                } else if (selectedType == 'Offline') {
                  events = events.where((e) => !e.isOnline).toList();
                }

                events.sort((a, b) => a.eventDate.compareTo(b.eventDate));

                return Column(
                  children: [
                    /// RESULTS COUNTER & RESET
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${events.length} Event Ditemukan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : AppTheme.textMutedLight,
                            ),
                          ),
                          if (hasActiveFilter)
                            GestureDetector(
                              onTap: _resetFilters,
                              child: const Row(
                                children: [
                                  Icon(Icons.refresh_rounded, size: 13, color: AppTheme.primary),
                                  SizedBox(width: 4),
                                  Text(
                                    'Reset Filter',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    /// EVENT LIST OR EMPTY STATE
                    Expanded(
                      child: events.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 58,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Event Tidak Ditemukan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white70 : AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Coba ganti kata kunci atau reset filter pencarian.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  if (hasActiveFilter) ...[
                                    const SizedBox(height: 16),
                                    TextButton.icon(
                                      onPressed: _resetFilters,
                                      icon: const Icon(Icons.refresh_rounded, size: 16),
                                      label: const Text('Reset Semua Filter'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.primary,
                                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                              itemCount: events.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 20),
                              itemBuilder: (context, i) {
                                return SizedBox(
                                  height: 265,
                                  child: EventCard(
                                    event: events[i],
                                    width: double.infinity,
                                    margin: EdgeInsets.zero,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ================= SEGMENTED CONTROL ITEM =================
  Widget _formatSegment(String label, String value, IconData icon, bool isDark) {
    final active = selectedType == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? (isDark ? AppTheme.cardDark : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: active
                    ? AppTheme.primary
                    : (isDark ? Colors.white60 : AppTheme.textMutedLight),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    color: active
                        ? (isDark ? Colors.white : AppTheme.textDark)
                        : (isDark ? Colors.white60 : AppTheme.textMutedLight),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

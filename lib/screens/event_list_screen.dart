import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';
import '../theme/app_theme.dart';

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

  final categories = ['All', 'Technology', 'Business', 'Health', 'Travel', 'Education'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Explore Events'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
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
                  hintText: 'Cari event, workshop, topik...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white30 : Colors.grey.shade400,
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),

          /// CATEGORY CHIPS
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final cat = categories[i];
                final active = cat == selectedCategory;

                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active
                          ? AppTheme.primary
                          : (isDark ? AppTheme.cardDark : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: active
                            ? Colors.transparent
                            : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                      ),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: active
                            ? Colors.white
                            : (isDark ? Colors.white70 : const Color(0xFF475569)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          /// FORMAT FILTER (ALL / ONLINE / OFFLINE)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _typeFilterChip('Semua Format', 'All', Icons.grid_view_rounded, isDark),
                const SizedBox(width: 8),
                _typeFilterChip('Online', 'Online', Icons.laptop_chromebook_rounded, isDark),
                const SizedBox(width: 8),
                _typeFilterChip('Offline Venue', 'Offline', Icons.place_rounded, isDark),
              ],
            ),
          ),

          const SizedBox(height: 14),

          /// EVENT LIST
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

                var events = snapshot.data!.docs
                    .map((e) => EventModel.fromFirestore(e))
                    .where((e) => e.title.toLowerCase().contains(search))
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

                if (events.isEmpty) {
                  return Center(
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
                      ],
                    ),
                  );
                }

                return ListView.separated(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeFilterChip(String label, String value, IconData icon, bool isDark) {
    final active = selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => selectedType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? (isDark ? const Color(0xFF2C3549) : const Color(0xFF1E2430))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? Colors.transparent
                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: active ? Colors.white : (isDark ? Colors.white60 : Colors.grey.shade600),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.w600,
                color: active ? Colors.white : (isDark ? Colors.white60 : Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

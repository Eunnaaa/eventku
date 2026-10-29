import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';
import 'ticket_service.dart';
import 'certificate_screen.dart';

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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleCancelTicket(BuildContext context, String ticketId, String? eventId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Batalkan Tiket?'),
        content: Text('Apakah kamu yakin ingin membatalkan pesanan tiket "$title"? Kursi akan dikembalikan untuk peserta lain.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await TicketService.cancelTicket(ticketId, eventId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.success,
              content: Text('Tiket berhasil dibatalkan.'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.danger,
              content: Text('Gagal membatalkan tiket: $e'),
            ),
          );
        }
      }
    }
  }

  void _showTicketPass(BuildContext context, Map<String, dynamic> data, String ticketId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Boarding Pass Digital',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF222938) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      /// EVENT TITLE
                      Text(
                        data['title']?.toString() ?? 'Event Pass',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${data['date'] ?? ''} • ${data['time'] ?? ''}',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['location']?.toString() ?? 'Lokasi menyusul',
                        style: TextStyle(
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          fontSize: 12,
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(),
                      ),

                      /// SIMULATED QR CODE PASS
                      Container(
                        width: 180,
                        height: 180,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _QrGridPainter(),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        'PASS ID: ${ticketId.substring(0, ticketId.length > 8 ? 8 : ticketId.length).toUpperCase()}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 2,
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        'Tunjukkan kode QR ini kepada panitia saat registrasi di pintu masuk.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// TICKET SPECS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _specItem('TIPE TIKET', 'General Pass', isDark),
                          _specItem('GATE', 'Utama', isDark),
                          _specItem('STATUS', (data['status']?.toString() ?? 'upcoming').toUpperCase(), isDark),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Silakan login terlebih dahulu')),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Tiket & Event Saya'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: AppTheme.primary,
              unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Aktif'),
                Tab(text: 'Riwayat'),
                Tab(text: 'Favorit'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ticketList(user.uid, 'upcoming', isDark),
          _ticketList(user.uid, 'completed', isDark),
          _bookmarksList(user.uid, isDark),
        ],
      ),
    );
  }

  /// ================= TICKET LIST =================
  Widget _ticketList(String uid, String status, bool isDark) {
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
          return _emptyState(status, isDark);
        }

        final docs = List<QueryDocumentSnapshot>.from(snapshot.data!.docs);
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aCreated = aData['createdAt'] as Timestamp?;
          final bCreated = bData['createdAt'] as Timestamp?;
          if (aCreated == null && bCreated == null) return 0;
          if (aCreated == null) return 1;
          if (bCreated == null) return -1;
          return bCreated.compareTo(aCreated);
        });

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final eventId = data['eventId']?.toString();
            final title = data['title']?.toString() ?? 'Event Pass';

            return GestureDetector(
              onTap: () => _showTicketPass(context, data, doc.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          /// TICKET ICON BADGE
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: status == 'upcoming'
                                    ? [AppTheme.primary, AppTheme.primaryLight]
                                    : [Colors.grey.shade600, Colors.grey.shade400],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.confirmation_number_rounded,
                              size: 26,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(width: 14),

                          /// CONTENT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: isDark ? Colors.white : AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_month, size: 12, color: AppTheme.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${data['date'] ?? ''} • ${data['time'] ?? ''}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        data['location']?.toString() ?? '-',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          /// QR CHEVRON
                          const Icon(Icons.qr_code_2_rounded, size: 30, color: AppTheme.primary),
                        ],
                      ),

                      if (status == 'upcoming') ...[
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ketuk untuk lihat QR Pass',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.danger,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: const Icon(Icons.cancel_outlined, size: 15),
                              label: const Text('Batalkan', style: TextStyle(fontSize: 12)),
                              onPressed: () => _handleCancelTicket(context, doc.id, eventId, title),
                            ),
                          ],
                        ),
                      ] else if (status == 'completed') ...[
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified_rounded, size: 15, color: AppTheme.success),
                                const SizedBox(width: 5),
                                Text(
                                  'Hadir Terverifikasi',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD97706),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.workspace_premium_rounded, size: 15),
                              label: const Text(
                                'E-Sertifikat',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CertificateScreen(
                                      ticketId: doc.id,
                                      eventTitle: title,
                                      attendeeName: data['attendeeName'] ?? data['name'] ?? FirebaseAuth.instance.currentUser?.displayName ?? 'Peserta EventKu',
                                      eventDate: data['date']?.toString() ?? '2026',
                                      speakerName: data['speaker']?.toString() ?? 'Panitia EventKu',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// ================= BOOKMARKS TAB =================
  Widget _bookmarksList(String uid, bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookmarkedDocs = snapshot.data?.docs ?? [];
        if (bookmarkedDocs.isEmpty) {
          return _emptyFavoritesState(isDark);
        }

        final eventIds = bookmarkedDocs.map((d) => d.id).toList();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('events').snapshots(),
          builder: (context, eventSnapshot) {
            if (!eventSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final events = eventSnapshot.data!.docs
                .map((e) => EventModel.fromFirestore(e))
                .where((e) => eventIds.contains(e.id))
                .toList();

            if (events.isEmpty) {
              return _emptyFavoritesState(isDark);
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, i) {
                return SizedBox(
                  height: 260,
                  child: EventCard(
                    event: events[i],
                    width: double.infinity,
                    margin: EdgeInsets.zero,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _emptyFavoritesState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: const Icon(Icons.bookmark_border_rounded, size: 36, color: AppTheme.primary),
            ),
            const SizedBox(height: 18),
            Text(
              'Belum Ada Event Disimpan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu bisa menekan ikon bookmark di halaman detail event untuk menyimpannya di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= EMPTY STATE =================
  Widget _emptyState(String status, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 36,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              status == 'upcoming' ? 'Belum Ada Tiket Aktif' : 'Belum Ada Riwayat Tiket',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status == 'upcoming'
                  ? 'Tiket event yang kamu pesan akan langsung muncul di sini.'
                  : 'Event yang sudah selesai dihadiri akan tersimpan di riwayat ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw a clean simulated QR code pattern without external library
class _QrGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    // Corner positioning boxes
    void drawCorner(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, 36, 36), paint);
      canvas.drawRect(
        Rect.fromLTWH(x + 6, y + 6, 24, 24),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(Rect.fromLTWH(x + 11, y + 11, 14, 14), paint);
    }

    drawCorner(0, 0);
    drawCorner(size.width - 36, 0);
    drawCorner(0, size.height - 36);

    // Simulated central matrix dots
    const int grid = 9;
    final step = size.width / grid;
    for (int i = 0; i < grid; i++) {
      for (int j = 0; j < grid; j++) {
        // Skip corner areas
        if ((i < 3 && j < 3) || (i >= grid - 3 && j < 3) || (i < 3 && j >= grid - 3)) {
          continue;
        }
        if ((i * 7 + j * 13) % 3 != 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(i * step + 2, j * step + 2, step - 4, step - 4),
              const Radius.circular(2),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';
import '../services/ticket_service.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool isBooking = false;

  Future<void> _handleBookTicket(EventModel currentEvent) async {
    if (isBooking) return;
    try {
      setState(() => isBooking = true);

      await TicketService.bookEvent(currentEvent);

      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 44),
                ),
                const SizedBox(height: 18),
                Text(
                  'Tiket Berhasil Dipesan!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tiket untuk "${currentEvent.title}" telah diterbitkan dan tersimpan di menu My Tickets.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Lihat Tiket Saya',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            content: Text(e.toString().replaceAll('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isBooking = false);
      }
    }
  }

  void _shareEvent(EventModel event) {
    final shareText = '''
Event: ${event.title}
Kategori: ${event.category}
Tanggal: ${event.date}
Waktu: ${event.time}
Lokasi: ${event.location}
Tipe: ${event.isOnline ? 'Online Webinar' : 'Tatap Muka (Offline)'}
Pembicara: ${event.speakerName}

Temukan dan pesan tiket gratis Anda sekarang di aplikasi EventKu!
'''.trim();

    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primary,
        content: Text('Rincian acara disalin ke papan klip. Siap dibagikan!'),
      ),
    );
  }

  void _addToCalendar(EventModel event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.event_available_rounded, color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Pengingat Kalender',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.date_range_rounded, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(event.date, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 16, color: AppTheme.accentBlue),
                      const SizedBox(width: 8),
                      Expanded(child: Text(event.time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.place_rounded, size: 16, color: AppTheme.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Simpan jadwal acara ini ke kalender pribadi Anda agar tidak terlewatkan.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white),
            label: const Text('Salin Jadwal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              final calEntry = 'Jadwal Acara: ${event.title}\nTanggal: ${event.date}\nWaktu: ${event.time}\nTempat: ${event.location}\nPengingat telah diset pada EventKu.';
              Clipboard.setData(ClipboardData(text: calEntry));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.success,
                  content: Text('Jadwal acara berhasil disalin! Masukkan ke aplikasi kalender Anda.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('events').doc(widget.event.id).snapshots(),
      builder: (context, snapshot) {
        EventModel event = widget.event;
        if (snapshot.hasData && snapshot.data!.exists) {
          event = EventModel.fromFirestore(snapshot.data!);
        }

        final remainingSeats = event.quota > 0 ? (event.quota - event.bookedCount) : 100;
        final isSoldOut = event.quota > 0 && remainingSeats <= 0;
        final eventDateTime = event.eventDate.toDate();
        final now = DateTime.now();
        final isPassed = now.isAfter(DateTime(eventDateTime.year, eventDateTime.month, eventDateTime.day, 23, 59, 59));
        final isUnpublished = !event.isPublished;
        final canBook = !isSoldOut && !isPassed && !isUnpublished;

        return Scaffold(
          backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  /// ================= APP BAR HEADER =================
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.45),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    actions: [
                      CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.45),
                        child: IconButton(
                          icon: const Icon(Icons.share_rounded, color: Colors.white, size: 19),
                          tooltip: 'Bagikan Acara',
                          onPressed: () => _shareEvent(event),
                        ),
                      ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: StreamBuilder<bool>(
                      stream: TicketService.isBookmarkedStream(event.id),
                      builder: (context, snap) {
                        final bookmarked = snap.data == true;
                        return CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.45),
                          child: IconButton(
                            icon: Icon(
                              bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              color: bookmarked ? AppTheme.primaryLight : Colors.white,
                              size: 20,
                            ),
                            tooltip: 'Simpan Favorit',
                            onPressed: () async {
                              final res = await TicketService.toggleBookmark(event.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(res ? 'Event disimpan ke favorit' : 'Dihapus dari favorit'),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        event.image.isNotEmpty
                            ? event.image
                            : 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return ColoredBox(
                            color: isDark ? const Color(0xFF1F2634) : const Color(0xFFE2E8F0),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2.5,
                                color: AppTheme.primaryLight,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Color(0xFF2E384D),
                          child: Icon(Icons.image_not_supported_rounded, size: 60, color: Colors.white38),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.88),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppTheme.primary, AppTheme.primaryLight],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    event.category.isNotEmpty ? event.category.toUpperCase() : 'GENERAL',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: event.isOnline ? Colors.indigo : Colors.teal,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        event.isOnline ? Icons.laptop_chromebook : Icons.place_rounded,
                                        color: Colors.white,
                                        size: 11,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        event.isOnline ? 'ONLINE WEBINAR' : 'OFFLINE EVENT',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              event.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                height: 1.25,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// ================= CONTENT BODY =================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// KUOTA & SEATS TILE
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.people_alt_outlined, color: AppTheme.primary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  isPassed
                                      ? 'Status Pelaksanaan Acara'
                                      : isUnpublished
                                          ? 'Status Pendaftaran'
                                          : isSoldOut
                                              ? 'Tiket Habis (Sold Out)'
                                              : 'Sisa Kursi Peserta',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: isDark ? Colors.white : AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: (isPassed || isUnpublished || isSoldOut)
                                    ? AppTheme.danger.withValues(alpha: 0.15)
                                    : AppTheme.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isPassed
                                    ? 'SELESAI'
                                    : isUnpublished
                                        ? 'DITUTUP'
                                        : isSoldOut
                                            ? 'SOLD OUT'
                                            : '$remainingSeats Kursi Tersedia',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: (isPassed || isUnpublished || isSoldOut)
                                      ? AppTheme.danger
                                      : AppTheme.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// INFO STATS TILES (TANGGAL, WAKTU, LOKASI)
                      _infoSection(event, isDark),

                      const SizedBox(height: 14),

                      /// QUICK ACTIONS: TAMBAH KE KALENDER & BAGIKAN ACARA
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(
                                  color: isDark ? Colors.white.withValues(alpha: 0.15) : AppTheme.primary.withValues(alpha: 0.3),
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.primary),
                              label: Text(
                                'Tambah Kalender',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppTheme.primary,
                                ),
                              ),
                              onPressed: () => _addToCalendar(event),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(
                                  color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.1),
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.share_outlined, size: 16, color: AppTheme.accentBlue),
                              label: Text(
                                'Bagikan Acara',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppTheme.accentBlue,
                                ),
                              ),
                              onPressed: () => _shareEvent(event),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// SPEAKER / PEMBICARA CARD
                      Text(
                        'Pembicara Utama',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppTheme.primaryLight,
                              child: Text(
                                (event.speakerName.isNotEmpty ? event.speakerName[0].toUpperCase() : 'S'),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.speakerName.isNotEmpty ? event.speakerName : 'Expert Speaker & Practitioner',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark ? Colors.white : AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    event.speakerRole.isNotEmpty ? event.speakerRole : 'Pemateri Ahli Bidang Terkait',
                                    style: TextStyle(
                                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// BENEFITS / FASILITAS EVENT
                      Text(
                        'Fasilitas & Keuntungan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: event.benefits.map((b) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.cardDark : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      b,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white70 : AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      /// RUNDOWN ACARA
                      Text(
                        'Rundown Acara',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppTheme.border(isDark),
                          ),
                        ),
                        child: Column(
                          children: [
                            _timelineRow('08:30 - 09:00', 'Registrasi & Morning Networking', false),
                            _timelineRow('09:00 - 10:30', 'Sesi Presentasi & Diskusi Utama', false),
                            _timelineRow('10:30 - 11:30', 'Sesi Tanya Jawab (QnA) & Kesimpulan', false),
                            _timelineRow('11:30 - 12:00', 'Foto Bersama & Penyerahan E-Sertifikat', true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// DESCRIPTION
                      Text(
                        'Tentang Event Ini',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppTheme.border(isDark),
                          ),
                        ),
                        child: Text(
                          event.description.isNotEmpty
                              ? event.description
                              : 'Ikuti event inspiratif ini untuk memperluas jejaring dan memperoleh ilmu praktis langsung dari para praktisi.',
                          style: TextStyle(
                            height: 1.6,
                            fontSize: 14,
                            color: isDark ? const Color(0xFFCBD5E1) : AppTheme.textMutedLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          /// ================= STICKY BOTTOM ACTION BAR =================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Biaya Masuk',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'GRATIS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.success,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !canBook ? Colors.grey.shade600 : AppTheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: (isBooking || !canBook) ? null : () => _handleBookTicket(event),
                        child: isBooking
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isPassed
                                        ? Icons.event_busy_rounded
                                        : isUnpublished
                                            ? Icons.lock_clock_rounded
                                            : isSoldOut
                                                ? Icons.block_rounded
                                                : Icons.confirmation_number_outlined,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isPassed
                                        ? 'Acara Selesai'
                                        : isUnpublished
                                            ? 'Pendaftaran Ditutup'
                                            : isSoldOut
                                                ? 'Kuota Penuh'
                                                : 'Dapatkan Tiket',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _timelineRow(String time, String title, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: AppTheme.primary.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoSection(EventModel event, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.calendar_month_rounded,
            'Tanggal Pelaksanaan',
            event.date.isNotEmpty ? event.date : 'TBD',
            AppTheme.primary,
            isDark,
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.access_time_filled_rounded,
            'Waktu Mulai',
            event.time.isNotEmpty ? event.time : 'TBD',
            AppTheme.accentBlue,
            isDark,
          ),
          const SizedBox(height: 16),
          _infoRow(
            event.isOnline ? Icons.laptop_mac_rounded : Icons.location_on_rounded,
            event.isOnline ? 'Tautan Platform' : 'Tempat / Venue',
            event.location.isNotEmpty ? event.location : 'Lokasi menyusul',
            AppTheme.success,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color iconColor, bool isDark) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

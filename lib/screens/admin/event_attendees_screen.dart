import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event_model.dart';
import '../../theme/admin_colors.dart';
import '../../theme/app_theme.dart';

class EventAttendeesScreen extends StatefulWidget {
  final EventModel event;

  const EventAttendeesScreen({super.key, required this.event});

  @override
  State<EventAttendeesScreen> createState() => _EventAttendeesScreenState();
}

class _EventAttendeesScreenState extends State<EventAttendeesScreen> {
  final _searchController = TextEditingController();
  String search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _exportToCsv(List<Map<String, dynamic>> tickets) {
    if (tickets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data peserta untuk diekspor')),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('No,Nama Peserta,Email,Status Kehadiran,Waktu Check-in,ID Tiket');

    int index = 1;
    for (final t in tickets) {
      final name = t['attendeeName'] ?? t['name'] ?? 'Peserta';
      final email = t['email'] ?? '-';
      final status = (t['status'] ?? 'upcoming').toString().toUpperCase();
      final ticketId = t['id'] ?? '-';

      String checkInTime = '-';
      final rawAttendedAt = t['attendedAt'];
      if (rawAttendedAt is Timestamp) {
        final dt = rawAttendedAt.toDate();
        checkInTime = '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute}';
      }

      buffer.writeln('$index,"$name","$email","$status","$checkInTime","$ticketId"');
      index++;
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.table_view_rounded, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Ekspor CSV Berhasil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sebanyak ${tickets.length} data peserta telah diformat sebagai CSV dan disalin ke Clipboard ponsel Anda.',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'Anda dapat langsung melakukan "Paste" ke Microsoft Excel, Google Sheets, atau aplikasi Spreadsheet lainnya.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Daftar Peserta Acara'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AdminColors.textDark,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('eventId', isEqualTo: widget.event.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 54, color: AppTheme.danger),
                    const SizedBox(height: 14),
                    Text(
                      'Gagal Memuat Daftar Peserta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AdminColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final allTickets = docs.map((d) {
            final data = d.data() as Map<String, dynamic>;
            return {...data, 'id': d.id};
          }).toList();

          final completedCount = allTickets.where((t) => t['status'] == 'completed').length;
          final upcomingCount = allTickets.where((t) => t['status'] == 'upcoming').length;
          final cancelledCount = allTickets.where((t) => t['status'] == 'cancelled').length;

          final filteredTickets = allTickets.where((t) {
            final name = (t['attendeeName'] ?? t['name'] ?? '').toString().toLowerCase();
            final id = t['id'].toString().toLowerCase();
            return name.contains(search) || id.contains(search);
          }).toList();

          return Column(
            children: [
              /// SUMMARY CARD
              Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border(isDark)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: isDark ? Colors.white : AdminColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.event.date} • Kuota: ${widget.event.bookedCount}/${widget.event.quota}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.textMutedDark : AdminColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricItem('Terdaftar', allTickets.length.toString(), AppTheme.primary, isDark),
                        _metricItem('Hadir (Check-in)', completedCount.toString(), AppTheme.success, isDark),
                        _metricItem('Upcoming', upcomingCount.toString(), AppTheme.accentBlue, isDark),
                        _metricItem('Batal', cancelledCount.toString(), AppTheme.danger, isDark),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Ekspor Rekap Peserta (CSV)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _exportToCsv(allTickets),
                      ),
                    ),
                  ],
                ),
              ),

              /// SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => search = v.trim().toLowerCase()),
                  style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
                  decoration: InputDecoration(
                    hintText: 'Cari nama peserta atau Pass ID...',
                    hintStyle: TextStyle(color: isDark ? AppTheme.textMutedDark : Colors.grey.shade400, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 20),
                    suffixIcon: search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => search = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.border(isDark)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// ATTENDEES LIST
              Expanded(
                child: filteredTickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off_rounded, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum ada peserta yang sesuai',
                              style: TextStyle(color: AdminColors.textGrey, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: filteredTickets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final ticket = filteredTickets[i];
                          final name = ticket['attendeeName'] ?? ticket['name'] ?? 'Peserta Terdaftar';
                          final status = ticket['status']?.toString() ?? 'upcoming';
                          final ticketId = ticket['id']?.toString() ?? '';
                          final passId = ticketId.substring(0, ticketId.length > 8 ? 8 : ticketId.length).toUpperCase();

                          Color statusColor;
                          String statusLabel;
                          if (status == 'completed') {
                            statusColor = AppTheme.success;
                            statusLabel = 'HADIR';
                          } else if (status == 'cancelled') {
                            statusColor = AppTheme.danger;
                            statusLabel = 'BATAL';
                          } else {
                            statusColor = AppTheme.accentBlue;
                            statusLabel = 'UPCOMING';
                          }

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.border(isDark)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: statusColor.withValues(alpha: 0.12),
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'P',
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isDark ? Colors.white : AppTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'PASS ID: $passId',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                          color: isDark ? AppTheme.textMutedDark : AdminColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _metricItem(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: isDark ? AppTheme.textMutedDark : AdminColors.textGrey, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

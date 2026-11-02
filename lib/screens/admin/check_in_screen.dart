import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/admin_colors.dart';
import '../../theme/app_theme.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _codeController = TextEditingController();
  bool isProcessing = false;
  String? selectedEventId;
  String? selectedEventTitle;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _processCheckIn(String code) async {
    final cleanCode = code.trim().toLowerCase();
    if (cleanCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Masukkan Kode Pass Tiket'),
        ),
      );
      return;
    }

    setState(() => isProcessing = true);

    try {
      // 1. Cari tiket berdasarkan Document ID langsung, ticketCode, atau range prefix
      DocumentSnapshot? ticketDoc;

      // Cek apakah code adalah Document ID lengkap
      final directDoc = await FirebaseFirestore.instance.collection('tickets').doc(cleanCode).get();
      if (directDoc.exists) {
        ticketDoc = directDoc;
      } else {
        // Cek via field ticketCode terindeks
        final byCodeQuery = await FirebaseFirestore.instance
            .collection('tickets')
            .where('ticketCode', isEqualTo: code.trim().toUpperCase())
            .limit(1)
            .get();

        if (byCodeQuery.docs.isNotEmpty) {
          ticketDoc = byCodeQuery.docs.first;
        } else {
          // Range query Firestore untuk prefix document ID (skala jutaan dokumen)
          final rangeQuery = await FirebaseFirestore.instance
              .collection('tickets')
              .orderBy(FieldPath.documentId)
              .startAt([cleanCode])
              .endAt(['$cleanCode\uf8ff'])
              .limit(1)
              .get();

          if (rangeQuery.docs.isNotEmpty) {
            ticketDoc = rangeQuery.docs.first;
          }
        }
      }

      if (ticketDoc == null || !ticketDoc.exists) {
        if (mounted) {
          _showResultDialog(
            isSuccess: false,
            title: 'Tiket Tidak Ditemukan',
            message: 'Kode Pass "$code" tidak terdaftar dalam sistem.',
          );
        }
        return;
      }

      final ticketData = ticketDoc.data() as Map<String, dynamic>;
      final status = ticketData['status']?.toString() ?? 'upcoming';
      final eventTitle = ticketData['title']?.toString() ?? 'Event';
      final userId = ticketData['userId']?.toString() ?? '';

      // Ambil nama peserta dari data users jika ada
      String attendeeName = 'Peserta Terdaftar';
      if (userId.isNotEmpty) {
        try {
          final userSnap = await FirebaseFirestore.instance.collection('users').doc(userId).get();
          if (userSnap.exists) {
            attendeeName = userSnap.data()?['fullName']?.toString() ?? attendeeName;
          }
        } catch (_) {}
      }

      // 2. Evaluasi status tiket
      if (status == 'completed') {
        final rawAttendedAt = ticketData['attendedAt'];
        String attendedTime = 'sebelumnya';
        if (rawAttendedAt is Timestamp) {
          final dt = rawAttendedAt.toDate();
          attendedTime = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
        }

        if (mounted) {
          _showResultDialog(
            isSuccess: false,
            title: 'Tiket Sudah Digunakan',
            message: 'Tiket atas nama $attendeeName sudah pernah check-in pada $attendedTime.',
          );
        }
        return;
      }

      if (status == 'cancelled' || status == 'event_cancelled') {
        final isEventCancelled = status == 'event_cancelled';
        if (mounted) {
          _showResultDialog(
            isSuccess: false,
            title: isEventCancelled ? 'Event Dibatalkan' : 'Tiket Telah Dibatalkan',
            message: isEventCancelled
                ? 'Acara untuk tiket ini telah dibatalkan oleh panitia penyelenggara.'
                : 'Tiket atas nama $attendeeName telah dibatalkan oleh pengguna.',
          );
        }
        return;
      }

      // Validasi Kesesuaian Acara (Cross-Event Gate Isolation)
      final ticketEventId = ticketData['eventId']?.toString();
      if (selectedEventId != null && selectedEventId!.isNotEmpty && ticketEventId != selectedEventId) {
        if (mounted) {
          _showResultDialog(
            isSuccess: false,
            title: 'Event Tidak Cocok',
            message: 'Tiket atas nama $attendeeName terdaftar untuk acara "$eventTitle", bukan untuk "${selectedEventTitle ?? 'event yang dipilih'}" di gate ini.',
          );
        }
        return;
      }

      // 3. Sukses: Validasi dan update status menjadi 'completed'
      await FirebaseFirestore.instance.collection('tickets').doc(ticketDoc.id).update({
        'status': 'completed',
        'attendedAt': Timestamp.now(),
        'attendeeName': attendeeName,
      });

      _codeController.clear();

      if (mounted) {
        _showResultDialog(
          isSuccess: true,
          title: 'Check-in Berhasil',
          message: 'Kehadiran $attendeeName telah berhasil diverifikasi untuk event "$eventTitle".',
          attendeeName: attendeeName,
          eventTitle: eventTitle,
          ticketId: ticketDoc.id,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            content: Text('Gagal memproses check-in: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  void _showResultDialog({
    required bool isSuccess,
    required String title,
    required String message,
    String? attendeeName,
    String? eventTitle,
    String? ticketId,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: (isSuccess ? AppTheme.success : AppTheme.danger).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isSuccess ? AppTheme.success : AppTheme.danger,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                height: 1.4,
              ),
            ),
            if (isSuccess && ticketId != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border(isDark)),
                ),
                child: Column(
                  children: [
                    Text(
                      'PASS ID: ${ticketId.substring(0, ticketId.length > 8 ? 8 : ticketId.length).toUpperCase()}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Status: HADIR (VERIFIED)', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? AppTheme.primary : (isDark ? AppTheme.surfaceDark : const Color(0xFF1E293B)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Verifikasi & Check-in Tiket'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AdminColors.textDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// GATE EVENT LOCK / SELECTOR
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .where('isPublished', isEqualTo: true)
                  .snapshots(),
              builder: (context, snap) {
                final events = snap.data?.docs ?? [];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selectedEventId != null ? AppTheme.primary : AppTheme.border(isDark),
                      width: selectedEventId != null ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selectedEventId != null ? Icons.verified_user_rounded : Icons.door_sliding_rounded,
                        color: selectedEventId != null ? AppTheme.primary : (isDark ? Colors.white60 : Colors.grey.shade600),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: selectedEventId,
                            isExpanded: true,
                            dropdownColor: isDark ? AppTheme.surfaceDark : Colors.white,
                            hint: Text(
                              'Pilih Acara untuk Gate Ini',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                              ),
                            ),
                            icon: Icon(Icons.arrow_drop_down_rounded, color: isDark ? Colors.white70 : Colors.black87),
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(
                                  'Semua Event (Mode Gate Terbuka)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppTheme.textDark,
                                  ),
                                ),
                              ),
                              ...events.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final title = data['title']?.toString() ?? 'Event';
                                return DropdownMenuItem<String?>(
                                  value: doc.id,
                                  child: Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : AppTheme.textDark,
                                    ),
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              setState(() {
                                selectedEventId = val;
                                if (val == null) {
                                  selectedEventTitle = null;
                                } else {
                                  final matching = events.where((d) => d.id == val).toList();
                                  if (matching.isNotEmpty) {
                                    selectedEventTitle = (matching.first.data() as Map<String, dynamic>)['title']?.toString();
                                  }
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            /// SIMULATED SCANNER VIEWFINDER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Pintu Masuk & Meja Registrasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pindai QR atau masukkan kode pass dari tiket peserta.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                  const SizedBox(height: 24),

                  /// SCAN RETICLE
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primary, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 90,
                            color: AppTheme.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 2,
                            width: 170,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Arahkan kamera ke QR Code peserta',
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// INPUT MANUAL KODE PASS
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(22),
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
                    'Input Manual Pass ID',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AdminColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ketik 8 karakter Pass ID yang tertera pada Boarding Pass.',
                    style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textMutedDark : AdminColors.textGrey),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 15,
                            color: isDark ? Colors.white : AppTheme.textDark,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Contoh: A1B2C3D4',
                            hintStyle: TextStyle(
                              fontFamily: 'monospace',
                              letterSpacing: 1,
                              fontSize: 13,
                              color: isDark ? AppTheme.textMutedDark : Colors.grey.shade400,
                            ),
                            prefixIcon: const Icon(Icons.pin_rounded, color: AppTheme.primary),
                            filled: true,
                            fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppTheme.border(isDark)),
                            ),
                          ),
                          onSubmitted: (v) => _processCheckIn(v),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: isProcessing ? null : () => _processCheckIn(_codeController.text),
                          child: isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Verifikasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// RIWAYAT CHECK-IN TERBARU
            Text(
              'Kehadiran Terbaru Hari Ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AdminColors.textDark,
              ),
            ),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tickets')
                  .where('status', isEqualTo: 'completed')
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                }

                final rawDocs = snapshot.data?.docs ?? [];
                final docs = List<QueryDocumentSnapshot>.from(rawDocs);
                docs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTime = aData['attendedAt'] as Timestamp?;
                  final bTime = bData['attendedAt'] as Timestamp?;
                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;
                  return bTime.compareTo(aTime);
                });
                if (docs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border(isDark)),
                    ),
                    child: Center(
                      child: Text(
                        'Belum ada peserta yang check-in hari ini.',
                        style: TextStyle(color: isDark ? AppTheme.textMutedDark : AdminColors.textGrey, fontSize: 13),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final title = data['title']?.toString() ?? 'Event';
                    final attendeeName = data['attendeeName']?.toString() ?? 'Peserta';
                    final rawAttendedAt = data['attendedAt'];
                    String timeStr = 'Baru saja';
                    if (rawAttendedAt is Timestamp) {
                      final dt = rawAttendedAt.toDate();
                      timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border(isDark)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded, color: AppTheme.success, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  attendeeName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark ? Colors.white : AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textMutedDark : AdminColors.textGrey),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppTheme.textMutedDark : Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

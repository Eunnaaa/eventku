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
      // 1. Cari tiket berdasarkan Document ID langsung atau prefix kode
      DocumentSnapshot? ticketDoc;

      // Cek apakah code adalah Document ID lengkap
      final directDoc = await FirebaseFirestore.instance.collection('tickets').doc(cleanCode).get();
      if (directDoc.exists) {
        ticketDoc = directDoc;
      } else {
        // Jika kode 8 karakter pertama, query dari Firestore
        final query = await FirebaseFirestore.instance
            .collection('tickets')
            .limit(100)
            .get();

        for (final doc in query.docs) {
          if (doc.id.toLowerCase().startsWith(cleanCode)) {
            ticketDoc = doc;
            break;
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

      if (status == 'cancelled') {
        if (mounted) {
          _showResultDialog(
            isSuccess: false,
            title: 'Tiket Telah Dibatalkan',
            message: 'Tiket atas nama $attendeeName telah dibatalkan oleh pengguna.',
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            ),
            if (isSuccess && ticketId != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    Text(
                      'PASS ID: ${ticketId.substring(0, ticketId.length > 8 ? 8 : ticketId.length).toUpperCase()}',
                      style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 13),
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
                  backgroundColor: isSuccess ? AppTheme.primary : const Color(0xFF1E293B),
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
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text('Verifikasi & Check-in Tiket'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AdminColors.textDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Input Manual Pass ID',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ketik 8 karakter Pass ID yang tertera pada Boarding Pass.',
                    style: TextStyle(fontSize: 12, color: AdminColors.textGrey),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Contoh: A1B2C3D4',
                            hintStyle: TextStyle(
                              fontFamily: 'monospace',
                              letterSpacing: 1,
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                            prefixIcon: const Icon(Icons.pin_rounded, color: AppTheme.primary),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
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
            const Text(
              'Kehadiran Terbaru Hari Ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AdminColors.textDark,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: const Center(
                      child: Text(
                        'Belum ada peserta yang check-in hari ini.',
                        style: TextStyle(color: AdminColors.textGrey, fontSize: 13),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
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
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: AdminColors.textGrey),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            timeStr,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary),
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

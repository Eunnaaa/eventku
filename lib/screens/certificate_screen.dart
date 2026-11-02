import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class CertificateScreen extends StatelessWidget {
  final String ticketId;
  final String eventTitle;
  final String attendeeName;
  final String eventDate;
  final String speakerName;

  const CertificateScreen({
    super.key,
    required this.ticketId,
    required this.eventTitle,
    required this.attendeeName,
    required this.eventDate,
    required this.speakerName,
  });

  @override
  Widget build(BuildContext context) {
    final certificateId = 'CERT-EKU-${ticketId.substring(0, ticketId.length > 8 ? 8 : ticketId.length).toUpperCase()}';
    final speaker = speakerName.isNotEmpty ? speakerName : 'Lead Instructor & Speaker';

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('E-Sertifikat Resmi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'E-Sertifikat EventKu: $eventTitle\nPenerima: $attendeeName\nNomor: $certificateId'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.success,
                  content: Text('Tautan dan nomor sertifikat disalin ke clipboard'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// CERTIFICATE FRAME
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: const Color(0xFFD4AF37), width: 3), // Gold border
              ),
              child: Column(
                children: [
                  /// CERTIFICATE BADGE & HEADER
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF5E4),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37)),
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, size: 40, color: Color(0xFFB8860B)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SERTIFIKAT PENGHARGAAN',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'SERTIFIKAT KELULUSAN RESMI SKP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Color(0xFFE2E8F0)),
                  ),

                  const Text(
                    'Diberikan dengan bangga kepada:',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// RECIPIENT NAME
                  Text(
                    attendeeName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Atas partisipasi aktif dan kelulusan penuh dalam sesi workshop & seminar:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// EVENT TITLE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      eventTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Diselenggarakan pada $eventDate',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),

                  const SizedBox(height: 28),

                  /// SIGNATURES SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 1,
                            width: 110,
                            color: Colors.black45,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            speaker,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                          const Text(
                            'Narasumber Utama',
                            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                        ),
                        child: const Icon(Icons.verified_rounded, size: 28, color: AppTheme.success),
                      ),
                      Column(
                        children: [
                          Container(
                            height: 1,
                            width: 110,
                            color: Colors.black45,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Panitia EventKu',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                          const Text(
                            'Verifikator Resmi',
                            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// CERTIFICATE NUMBER & VERIFICATION
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ID: $certificateId',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.check_circle, size: 12, color: AppTheme.success),
                            SizedBox(width: 4),
                            Text(
                              'VERIFIED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.success,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ACTION BUTTONS
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                label: const Text('Salin Nomor Sertifikat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: certificateId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.success,
                      content: Text('Nomor sertifikat berhasil disalin'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

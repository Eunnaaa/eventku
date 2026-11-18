import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event_model.dart';
import '../../theme/app_theme.dart';
import '../../theme/admin_colors.dart';
import '../../services/admin_event_service.dart';

class EventFormScreen extends StatefulWidget {
  final EventModel? event;
  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final title = TextEditingController();
  final category = TextEditingController();
  final date = TextEditingController();
  final time = TextEditingController();
  final location = TextEditingController();
  final description = TextEditingController();
  final image = TextEditingController();
  final quota = TextEditingController();
  final speakerName = TextEditingController();
  final speakerRole = TextEditingController();

  bool isOnline = false;
  bool isSaving = false;
  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      final ev = widget.event!;
      title.text = ev.title;
      category.text = ev.category;
      date.text = ev.date;
      selectedDateTime = ev.eventDate.toDate();
      time.text = ev.time;
      location.text = ev.location;
      description.text = ev.description;
      image.text = ev.image;
      quota.text = ev.quota.toString();
      speakerName.text = ev.speakerName;
      speakerRole.text = ev.speakerRole;
      isOnline = ev.isOnline;
    } else {
      quota.text = '100';
      category.text = 'Technology';
    }
  }

  @override
  void dispose() {
    title.dispose();
    category.dispose();
    date.dispose();
    time.dispose();
    location.dispose();
    description.dispose();
    image.dispose();
    quota.dispose();
    speakerName.dispose();
    speakerRole.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        selectedDateTime = picked;
        date.text = EventModel.formatDate(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        time.text = '$hour:$minute';
      });
    }
  }

  Future<void> submit() async {
    final titleText = title.text.trim();
    final categoryText = category.text.trim();
    final dateText = date.text.trim();
    final timeText = time.text.trim();
    final locationText = location.text.trim();
    final descText = description.text.trim();
    final imgText = image.text.trim();
    final parsedQuota = int.tryParse(quota.text.trim()) ?? 100;

    if (titleText.isEmpty || dateText.isEmpty || locationText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Judul, Tanggal, dan Lokasi wajib diisi'),
        ),
      );
      return;
    }

    if (parsedQuota < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Kuota peserta minimal harus 1 tiket'),
        ),
      );
      return;
    }

    try {
      setState(() => isSaving = true);

      final eventDateTimestamp = selectedDateTime != null
          ? Timestamp.fromDate(selectedDateTime!)
          : EventModel.parseDate(null, dateText);

      final event = EventModel(
        id: widget.event?.id ?? '',
        title: titleText,
        category: categoryText.isNotEmpty ? categoryText : 'General',
        date: dateText,
        eventDate: eventDateTimestamp,
        time: timeText,
        location: locationText,
        description: descText,
        image: imgText,
        createdAt: widget.event?.createdAt ?? Timestamp.now(),
        isPublished: widget.event?.isPublished ?? true,
        quota: parsedQuota,
        bookedCount: widget.event?.bookedCount ?? 0,
        speakerName: speakerName.text.trim(),
        speakerRole: speakerRole.text.trim(),
        isOnline: isOnline,
        benefits: widget.event?.benefits ?? const [
          'E-Sertifikat Resmi Bernilai SKP',
          'Materi & Rekaman Presentasi',
          'Snack Box & Konsumsi',
          'Networking Session',
        ],
      );

      if (widget.event == null) {
        await AdminEventService.createEvent(event);
      } else {
        await AdminEventService.updateEvent(event);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.success,
            content: Text(widget.event == null ? 'Event berhasil dibuat' : 'Event berhasil diperbarui'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.danger,
            content: Text('Gagal menyimpan event: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(widget.event == null ? 'Buat Event Baru' : 'Edit Event'),
        foregroundColor: isDark ? Colors.white : AdminColors.textDark,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            /// SECTION: INFORMASI UTAMA
            _sectionCard(
              title: 'Informasi Acara',
              children: [
                _input(title, 'Judul Acara *', hint: 'Contoh: Tech Summit 2026'),
                _input(category, 'Kategori', hint: 'Health, Business, Travel, Technology'),
                _input(description, 'Deskripsi Acara', maxLines: 3, hint: 'Jelaskan topik materi dan keunggulan acara...'),
                _input(image, 'Tautan Poster Gambar (URL)', hint: 'https://images.unsplash.com/...'),
              ],
            ),

            const SizedBox(height: 18),

            /// SECTION: JADWAL & LOKASI
            _sectionCard(
              title: 'Jadwal & Lokasi',
              children: [
                _input(
                  date,
                  'Tanggal Pelaksanaan *',
                  hint: 'Pilih tanggal acara',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.primary),
                    onPressed: _pickDate,
                  ),
                ),
                _input(
                  time,
                  'Waktu Mulai',
                  hint: 'Contoh: 09:00',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time_filled_rounded, color: AppTheme.primary),
                    onPressed: _pickTime,
                  ),
                ),
                _input(location, 'Lokasi / Tautan Platform *', hint: 'Gedung Serbaguna atau Zoom Link'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Format Acara Online (Webinar)',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Switch(
                      value: isOnline,
                      activeThumbColor: AppTheme.primary,
                      onChanged: (v) => setState(() => isOnline = v),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// SECTION: NARASUMBER & KUOTA
            _sectionCard(
              title: 'Narasumber & Kuota Peserta',
              children: [
                _input(speakerName, 'Nama Pembicara Utama', hint: 'Contoh: Dr. Jane Doe'),
                _input(speakerRole, 'Peran / Jabatan Pembicara', hint: 'Contoh: Lead AI Scientist'),
                _input(quota, 'Kuota Maksimal Kursi', keyboardType: TextInputType.number, hint: '100'),
              ],
            ),

            const SizedBox(height: 28),

            /// SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: isSaving ? null : submit,
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        widget.event == null ? 'Terbitkan Event' : 'Perbarui Event',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}

  Widget _sectionCard({required String title, required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AdminColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String label, {
    String? hint,
    int maxLines = 1,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textMutedDark : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppTheme.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: isDark ? AppTheme.textMutedDark : Colors.grey.shade400, fontSize: 13),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppTheme.border(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppTheme.border(isDark)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

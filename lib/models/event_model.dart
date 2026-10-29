import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String category;
  final String date;
  final Timestamp eventDate; // Native Timestamp for accurate range queries & chronological sorting
  final String time;
  final String location;
  final String description;
  final String image;
  final Timestamp createdAt;
  final bool isPublished;
  final int quota;
  final int bookedCount;
  final String speakerName;
  final String speakerRole;
  final bool isOnline;
  final List<String> benefits;

  EventModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.eventDate,
    required this.time,
    required this.location,
    required this.description,
    required this.image,
    required this.createdAt,
    required this.isPublished,
    this.quota = 100,
    this.bookedCount = 0,
    this.speakerName = '',
    this.speakerRole = '',
    this.isOnline = false,
    this.benefits = const [
      'E-Sertifikat Resmi Bernilai SKP',
      'Materi & Rekaman Presentasi',
      'Snack Box & Makan Siang',
      'Exclusive Networking Session',
    ],
  });

  /// Helper untuk memformat DateTime menjadi format teks standar (contoh: '15 Nov 2026')
  static String formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  /// Helper cerdas untuk mem-parsing data tanggal baik dari Timestamp, teks legacy, atau ISO string
  static Timestamp parseDate(dynamic rawEventDate, dynamic rawDateString) {
    if (rawEventDate is Timestamp) {
      return rawEventDate;
    }
    if (rawDateString is Timestamp) {
      return rawDateString;
    }
    if (rawDateString is String && rawDateString.trim().isNotEmpty) {
      final parts = rawDateString.trim().split(RegExp(r'\s+'));
      if (parts.length >= 3) {
        final day = int.tryParse(parts[0]);
        final monthStr = parts[1].toLowerCase();
        final year = int.tryParse(parts[2]);
        const months = {
          'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'mei': 5,
          'jun': 6, 'jul': 7, 'aug': 8, 'agu': 8, 'sep': 9, 'oct': 10,
          'okt': 10, 'nov': 11, 'dec': 12, 'des': 12
        };
        final month = months[monthStr.length >= 3 ? monthStr.substring(0, 3) : monthStr];
        if (day != null && month != null && year != null) {
          try {
            return Timestamp.fromDate(DateTime(year, month, day));
          } catch (_) {}
        }
      }
      try {
        final parsed = DateTime.tryParse(rawDateString);
        if (parsed != null) {
          return Timestamp.fromDate(parsed);
        }
      } catch (_) {}
    }
    return Timestamp.now();
  }

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    Timestamp parsedCreatedAt;
    final rawCreatedAt = data['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt;
    } else {
      parsedCreatedAt = Timestamp.now();
    }

    final parsedEventDate = parseDate(data['eventDate'], data['date']);
    final rawDateText = data['date']?.toString() ?? '';
    final formattedDateText = rawDateText.isNotEmpty ? rawDateText : formatDate(parsedEventDate.toDate());

    final rawBenefits = data['benefits'];
    List<String> parsedBenefits = const [
      'E-Sertifikat Resmi',
      'Materi & Rekaman Presentasi',
      'Snack & Konsumsi',
      'Networking Session',
    ];

    if (rawBenefits is List && rawBenefits.isNotEmpty) {
      parsedBenefits = rawBenefits.map((e) => e.toString()).toList();
    }

    final rawQuota = data['quota'];
    final rawBooked = data['bookedCount'];

    return EventModel(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      date: formattedDateText,
      eventDate: parsedEventDate,
      time: data['time']?.toString() ?? '',
      location: data['location']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      image: data['image']?.toString() ?? '',
      createdAt: parsedCreatedAt,
      isPublished: data['isPublished'] == true,
      quota: (rawQuota is num) ? rawQuota.toInt() : 100,
      bookedCount: (rawBooked is num) ? rawBooked.toInt() : 0,
      speakerName: data['speakerName']?.toString() ?? '',
      speakerRole: data['speakerRole']?.toString() ?? '',
      isOnline: data['isOnline'] == true,
      benefits: parsedBenefits,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'date': date,
      'eventDate': eventDate, // Field Timestamp asli untuk query Firestore
      'time': time,
      'location': location,
      'description': description,
      'image': image,
      'createdAt': createdAt,
      'isPublished': isPublished,
      'quota': quota,
      'bookedCount': bookedCount,
      'speakerName': speakerName,
      'speakerRole': speakerRole,
      'isOnline': isOnline,
      'benefits': benefits,
    };
  }
}

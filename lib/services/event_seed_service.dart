import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import 'admin_event_service.dart';

class EventSeedService {
  /// Daftar event sampel berkualitas tinggi untuk masing-masing kategori
  static List<EventModel> getSampleEvents() {
    return [
      /// ================= CATEGORY: TECHNOLOGY =================
      EventModel(
        id: '',
        title: 'Flutter 3.x & AI Assistant Deep Dive Workshop',
        category: 'Technology',
        date: '15 Nov 2026',
        eventDate: Timestamp.fromDate(DateTime(2026, 11, 15, 9, 0)),
        time: '09:00 - 15:30 WIB',
        location: 'Auditorium Cyber 2 Tower, Kuningan, Jakarta Selatan',
        description: 'Pelajari implementasi arsitektur mobile Flutter modern dan integrasi generative AI untuk aplikasi produksi enterprise.',
        image: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800&auto=format&fit=crop&q=80',
        createdAt: Timestamp.now(),
        isPublished: true,
        quota: 120,
        bookedCount: 0,
        speakerName: 'Budi Rahardjo, Ph.D.',
        speakerRole: 'Principal Mobile Architect & IT Specialist',
        isOnline: false,
        benefits: const [
          'E-Sertifikat Resmi Bernilai SKP',
          'Repository Source Code Lengkap',
          'Snack Box & Makan Siang',
          'Akses Rekaman Video HD 1 Tahun',
        ],
      ),
      EventModel(
        id: '',
        title: 'Cloud Native & Microservices Architecture Summit 2026',
        category: 'Technology',
        date: '28 Nov 2026',
        eventDate: Timestamp.fromDate(DateTime(2026, 11, 28, 13, 0)),
        time: '13:00 - 17:00 WIB',
        location: 'Online Webinar (Zoom Live Streaming)',
        description: 'Membahas orkestrasi Kubernetes, observability sistem terdistribusi, dan strategi migrasi arsitektur skala besar.',
        image: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop&q=80',
        createdAt: Timestamp.now(),
        isPublished: true,
        quota: 300,
        bookedCount: 0,
        speakerName: 'Dr. Eng. Irvan Pratama',
        speakerRole: 'Head of Cloud Infrastructure Solutions',
        isOnline: true,
        benefits: const [
          'E-Sertifikat Kehadiran Resmi',
          'Slide Materi Eksklusif & E-Book',
          'Sesi Konsultasi QnA Interaktif',
        ],
      ),
      EventModel(
        id: '',
        title: 'Cybersecurity Defense & Zero-Trust Framework 2026',
        category: 'Technology',
        date: '10 Dec 2026',
        eventDate: Timestamp.fromDate(DateTime(2026, 12, 10, 10, 0)),
        time: '10:00 - 16:00 WIB',
        location: 'Indonesia Convention Exhibition (ICE BSD), Tangerang',
        description: 'Strategi ketahanan siber terpadu, pencegahan ransomware, dan implementasi kepatuhan privasi data perbankan.',
        image: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=800&auto=format&fit=crop&q=80',
        createdAt: Timestamp.now(),
        isPublished: true,
        quota: 150,
        bookedCount: 0,
        speakerName: 'Rian Hidayat, CISSP',
        speakerRole: 'Lead Security Operations & Penetration Tester',
        isOnline: false,
        benefits: const [
          'E-Sertifikat Kompetensi Keamanan Siber',
          'Tooling Kit & Lab Simulasi Serangan',
          'Exclusive Networking Lunch',
        ],
      ),

      /// ================= CATEGORY: BUSINESS =================
      EventModel(
        id: '',
        title: 'SaaS Growth & Startup Venture Fundraising Masterclass',
        category: 'Business',
        date: '20 Nov 2026',
        eventDate: Timestamp.fromDate(DateTime(2026, 11, 20, 10, 0)),
        time: '10:00 - 16:30 WIB',
        location: 'SCBD Financial Hall Lt. 28, Sudirman, Jakarta',
        description: 'Kupas tuntas metrik unit economics (CAC, LTV, NRR), valuasi bisnis rintisan, dan teknik pitch deck di hadapan Venture Capital.',
        image: 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=800&auto=format&fit=crop&q=80',
        createdAt: Timestamp.now(),
        isPublished: true,
        quota: 80,
        bookedCount: 0,
        speakerName: 'Amanda Santoso, MBA',
        speakerRole: 'Partner at Nusantara Ventures Capital',
        isOnline: false,
        benefits: const [
          'E-Sertifikat Eksekutif Bisnis',
          'Pitch Deck Template & Financial Model',
          'VIP Networking Cocktail Session',
        ],
      ),
      EventModel(
        id: '',
        title: 'Digital Marketing & Omnichannel Brand Positioning',
        category: 'Business',
        date: '5 Dec 2026',
        eventDate: Timestamp.fromDate(DateTime(2026, 12, 5, 14, 0)),
        time: '14:00 - 17:30 WIB',
        location: 'Online Webinar (Google Meet Live)',
        description: 'Membangun corong konversi multichannel berbasis data dan optimasi kampanye media sosial berkinerja tinggi.',
        image: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&auto=format&fit=crop&q=80',
        createdAt: Timestamp.now(),
        isPublished: true,
        quota: 250,
        bookedCount: 0,
        speakerName: 'Kevin Wijaya',
        speakerRole: 'Growth Marketing Director at TokoTech',
        isOnline: true,
        benefits: const [
          'E-Sertifikat Digital Marketing',
          'Marketing Budget Calculator Excel',
          'Akses Rekaman Video & Bahan Bacaan',
        ],
      ),

      /// ================= CATEGORY: HEALTH =================
      EventModel(
        id: '',
        title: 'Holistic Wellness & Preventive Longevity Expo 2026',
        category: 'Health',
        date: '22 Nov 2026',
        eventDate: Timestamp.fromDate(DateTime(2026, 11, 22, 8, 30)),
        time: '08:30 - 15:00 WIB',
        location: 'Balai Kartini Exhibition Hall, Gatot Subroto, Jakarta',
        description: 'Simposium kesehatan holistik, nutrisi bio-individual, pencegahan penyakit kronis, dan pemeriksaan kesehatan gratis.',
        image: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&auto=format&fit=crop&q=80',
        createdAt: Timestamp.now(),
        isPublished: true,
        quota: 200,
        bookedCount: 0,
        speakerName: 'dr. Tirta Wibowo, Sp.GK',
        speakerRole: 'Dokter Spesialis Gizi Klinis & Wellness Advisor',
        isOnline: false,
        benefits: const [
          'E-Sertifikat Health & Wellness',
          'Free Pemeriksaan Komposisi Tubuh',
          'Healthy Lunch Box Organik',
          'Goodie Bag Produk Nutrisi Sehat',
        ],
      ),
      EventModel(
        id: '',
        title: 'Mental Health & Burnout Prevention for Professionals',
        category: 'Health',
        date: '8 Dec 2026',
        eventDate: Timestamp.fromDate(DateTime(2026, 12, 8, 19, 0)),
        time: '19:00 - 21:00 WIB',
        location: 'Online Webinar (Zoom Interactive Session)',
        description: 'Strategi mengatasi stres kerja, regulasi emosi, mindfulness harian, dan menjaga keseimbangan mental pekerja urban.',
        image: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&auto=format&fit=crop&q=80',
        createdAt: Timestamp.now(),
        isPublished: true,
        quota: 350,
        bookedCount: 0,
        speakerName: 'Siti Rahma, M.Psi., Psikolog',
        speakerRole: 'Psikolog Klinis & Konsultan Wellbeing',
        isOnline: true,
        benefits: const [
          'E-Sertifikat Partisipasi',
          'Self-Reflection Workbook PDF',
          'Panduan Audio Meditasi Terpandu',
        ],
      ),

      /// ================= CATEGORY: TRAVEL =================
      EventModel(
        id: '',
        title: 'Sustainable Ecotourism & Hidden Gems of Indonesia Expo',
        category: 'Travel',
        date: '12 Dec 2026',
        eventDate: Timestamp.fromDate(DateTime(2026, 12, 12, 10, 0)),
        time: '10:00 - 18:00 WIB',
        location: 'Bali Nusa Dua Convention Center (BNDCC), Bali',
        description: 'Pameran pariwisata berkelanjutan, eksplorasi desa wisata Nusantara, dan panggung diskusi kelestarian maritim.',
        image: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
        createdAt: Timestamp.now(),
        isPublished: true,
        quota: 250,
        bookedCount: 0,
        speakerName: 'Wayan Suryawan',
        speakerRole: 'Eco-Tourism Specialist & Culture Ambassador',
        isOnline: false,
        benefits: const [
          'E-Sertifikat Pameran Pariwisata',
          'Voucher Diskon Paket Wisata Desa 25%',
          'Kuliner Khas Nusantara & Souvenir Tradisional',
        ],
      ),
      EventModel(
        id: '',
        title: 'Solo Travel & Digital Nomad Lifestyle in Southeast Asia',
        category: 'Travel',
        date: '18 Dec 2026',
        eventDate: Timestamp.fromDate(DateTime(2026, 12, 18, 15, 0)),
        time: '15:00 - 17:30 WIB',
        location: 'Online Webinar (Live YouTube Community)',
        description: 'Tips anggaran backpacker, keselamatan perjalanan mandiri, visa nomad digital, dan etika berbaur dengan warga lokal.',
        image: 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800&auto=format&fit=crop&q=80',
        createdAt: Timestamp.now(),
        isPublished: true,
        quota: 400,
        bookedCount: 0,
        speakerName: 'Dimas Anggara',
        speakerRole: 'Travel Documentarian & Remote Worker',
        isOnline: true,
        benefits: const [
          'E-Sertifikat Komunitas Traveler',
          'E-Book: 50 Kota Ramah Digital Nomad di Asia',
          'Akses Grup Komunitas Backpacker Asia',
        ],
      ),

      /// ================= CATEGORY: EDUCATION =================
      EventModel(
        id: '',
        title: 'Modern AI-Assisted Pedagogy & Curriculum Design 2026',
        category: 'Education',
        date: '20 Dec 2026',
        eventDate: Timestamp.fromDate(DateTime(2026, 12, 20, 9, 0)),
        time: '09:00 - 15:00 WIB',
        location: 'Auditorium Gedung Kebudayaan UPI, Bandung',
        description: 'Transformasi metodologi pengajaran interaktif dan pemanfaatan perangkat AI untuk pembelajaran abad ke-21.',
        image: 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=800&auto=format&fit=crop&q=80',
        createdAt: Timestamp.now(),
        isPublished: true,
        quota: 150,
        bookedCount: 0,
        speakerName: 'Prof. Dr. Hendra Gunawan',
        speakerRole: 'Guru Besar Kurikulum & Teknologi Pendidikan',
        isOnline: false,
        benefits: const [
          'E-Sertifikat Resmi Bernilai 32 JP',
          'Kumpulan Modul Pembelajaran Interaktif',
          'Snack Box & Makan Siang',
        ],
      ),
    ];
  }

  /// Memasukkan data event sampel ke Firestore jika belum ada
  static Future<int> seedAllCategories() async {
    final sampleList = getSampleEvents();
    int addedCount = 0;

    // Ambil daftar judul event yang sudah ada di database untuk mencegah duplikasi
    final existingSnapshot = await FirebaseFirestore.instance.collection('events').get();
    final existingTitles = existingSnapshot.docs
        .map((d) => (d.data()['title'] ?? '').toString().trim().toLowerCase())
        .toSet();

    for (final ev in sampleList) {
      if (!existingTitles.contains(ev.title.trim().toLowerCase())) {
        await AdminEventService.createEvent(ev);
        addedCount++;
      }
    }

    return addedCount;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';

class TicketService {
  /// Memesan tiket dengan Firestore Transaction (ACID, Anti-Race Condition & Anti-Overbooking)
  static Future<void> bookEvent(EventModel event) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu untuk memesan tiket');
    }

    // 1. Cek apakah user sudah memiliki tiket aktif untuk event ini
    final existing = await FirebaseFirestore.instance
        .collection('tickets')
        .where('userId', isEqualTo: user.uid)
        .where('eventId', isEqualTo: event.id)
        .where('status', isEqualTo: 'upcoming')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Kamu sudah memiliki tiket aktif untuk event ini');
    }

    // 2. Ambil profil pengguna
    String attendeeName = user.displayName ?? '';
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        final uData = userDoc.data()!;
        attendeeName = uData['fullName']?.toString() ?? attendeeName;
      }
    } catch (_) {}

    if (attendeeName.trim().isEmpty) {
      attendeeName = (user.email != null && user.email!.contains('@'))
          ? user.email!.split('@').first
          : 'Peserta Event';
    }

    final eventRef = FirebaseFirestore.instance.collection('events').doc(event.id);
    final userBookingRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('active_bookings')
        .doc(event.id);
    final ticketRef = FirebaseFirestore.instance.collection('tickets').doc();
    final shortTicketCode = ticketRef.id.substring(0, ticketRef.id.length >= 8 ? 8 : ticketRef.id.length).toUpperCase();

    // 3. Eksekusi Atomic Transaction
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // 3a. Validasi reservasi aktif di level transaksi atomik (Anti-Double Booking)
      final bookingSnap = await transaction.get(userBookingRef);
      if (bookingSnap.exists) {
        throw Exception('Kamu sudah memiliki tiket aktif untuk event ini');
      }

      final eventDoc = await transaction.get(eventRef);

      if (!eventDoc.exists) {
        throw Exception('Event tidak ditemukan atau telah dihapus oleh panitia');
      }

      final freshData = eventDoc.data() ?? {};
      
      // Validasi Status Publikasi Acara
      if (freshData['isPublished'] == false) {
        throw Exception('Mohon maaf, pendaftaran untuk event ini sedang ditutup atau dinonaktifkan oleh panitia.');
      }

      // Validasi Tanggal Kedaluwarsa Acara
      final rawEventDate = freshData['eventDate'];
      DateTime? eventDate;
      if (rawEventDate is Timestamp) {
        eventDate = rawEventDate.toDate();
      } else if (freshData['date'] != null) {
        eventDate = EventModel.parseDate(null, freshData['date']).toDate();
      }

      if (eventDate != null) {
        final now = DateTime.now();
        final endOfEventDay = DateTime(eventDate.year, eventDate.month, eventDate.day, 23, 59, 59);
        if (now.isAfter(endOfEventDay)) {
          throw Exception('Pendaftaran ditutup: Tanggal penyelenggaraan event ini telah berakhir.');
        }
      }

      final freshQuota = (freshData['quota'] is num) ? (freshData['quota'] as num).toInt() : event.quota;
      final freshBooked = (freshData['bookedCount'] is num) ? (freshData['bookedCount'] as num).toInt() : 0;

      if (freshQuota > 0 && freshBooked >= freshQuota) {
        throw Exception('Mohon maaf, kuota tiket untuk event ini sudah habis (Sold Out)!');
      }

      // Buat tiket dengan data lengkap dan kode pass terindeks
      transaction.set(ticketRef, {
        'ticketCode': shortTicketCode,
        'userId': user.uid,
        'attendeeName': attendeeName,
        'email': user.email ?? '-',
        'eventId': event.id,
        'title': event.title,
        'category': event.category,
        'date': event.date,
        'eventDate': event.eventDate,
        'time': event.time,
        'location': event.location,
        'image': event.image,
        'speaker': event.speakerName,
        'status': 'upcoming',
        'createdAt': Timestamp.now(),
      });

      // Catat reservasi aktif pengguna untuk proteksi ACID
      transaction.set(userBookingRef, {
        'ticketId': ticketRef.id,
        'eventId': event.id,
        'bookedAt': Timestamp.now(),
      });

      // Update bookedCount secara atomik
      transaction.update(eventRef, {
        'bookedCount': freshBooked + 1,
      });
    });
  }

  /// Membatalkan tiket secara atomik dengan validasi status tiket
  static Future<void> cancelTicket(String ticketId, String? eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Pengguna tidak login');

    final ticketRef = FirebaseFirestore.instance.collection('tickets').doc(ticketId);
    DocumentReference? eventRef;
    if (eventId != null && eventId.isNotEmpty) {
      eventRef = FirebaseFirestore.instance.collection('events').doc(eventId);
    }

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final ticketSnap = await transaction.get(ticketRef);
      if (!ticketSnap.exists) {
        throw Exception('Tiket tidak ditemukan');
      }

      final ticketData = ticketSnap.data() as Map<String, dynamic>;
      final currentStatus = ticketData['status']?.toString();

      if (currentStatus != 'upcoming') {
        throw Exception('Hanya tiket dengan status aktif yang dapat dibatalkan');
      }

      // Validasi Batas Waktu Pembatalan (Cancellation Deadline)
      final rawEventDate = ticketData['eventDate'];
      DateTime? eventDate;
      if (rawEventDate is Timestamp) {
        eventDate = rawEventDate.toDate();
      }
      if (eventDate != null) {
        final now = DateTime.now();
        final startOfEventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
        if (now.isAfter(startOfEventDay)) {
          throw Exception('Tiket tidak dapat dibatalkan pada hari pelaksanaan atau setelah acara dimulai.');
        }
      }

      transaction.update(ticketRef, {
        'status': 'cancelled',
        'cancelledAt': Timestamp.now(),
      });

      // Hapus dari active_bookings agar kuota hak reservasi user terbebas
      final targetEventId = eventId ?? ticketData['eventId']?.toString();
      if (targetEventId != null && targetEventId.isNotEmpty) {
        final activeBookingRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('active_bookings')
            .doc(targetEventId);
        transaction.delete(activeBookingRef);
      }

      if (eventRef != null) {
        final targetEventRef = eventRef;
        final eventSnap = await transaction.get(targetEventRef);
        if (eventSnap.exists) {
          final eventData = eventSnap.data() as Map<String, dynamic>;
          final currentBooked = (eventData['bookedCount'] is num) ? (eventData['bookedCount'] as num).toInt() : 0;
          if (currentBooked > 0) {
            transaction.update(targetEventRef, {
              'bookedCount': currentBooked - 1,
            });
          }
        }
      }
    });
  }

  /// BOOKMARK / FAVORITE LOGIC
  static Future<bool> toggleBookmark(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(eventId);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
      return false; // Removed
    } else {
      await docRef.set({
        'eventId': eventId,
        'savedAt': Timestamp.now(),
      });
      return true; // Added
    }
  }

  static Stream<bool> isBookmarkedStream(String eventId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(false);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(eventId)
        .snapshots()
        .map((s) => s.exists);
  }
}

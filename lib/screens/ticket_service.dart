import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';

class TicketService {
  static Future<void> bookEvent(EventModel event) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu untuk memesan tiket');
    }

    // Cek apakah user sudah memiliki tiket aktif untuk event ini
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

    // Ambil data terbaru dari Firestore untuk menghindari stale quota
    final eventRef = FirebaseFirestore.instance.collection('events').doc(event.id);
    final freshDoc = await eventRef.get();

    if (freshDoc.exists) {
      final freshData = freshDoc.data() ?? {};
      final freshQuota = (freshData['quota'] is num) ? (freshData['quota'] as num).toInt() : event.quota;
      final freshBooked = (freshData['bookedCount'] is num) ? (freshData['bookedCount'] as num).toInt() : 0;

      if (freshQuota > 0 && freshBooked >= freshQuota) {
        throw Exception('Mohon maaf, kuota tiket untuk event ini sudah habis (Sold Out)!');
      }
    }

    // Ambil nama profil pengguna untuk sinkronisasi tiket & rekap admin
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

    await FirebaseFirestore.instance.collection('tickets').add({
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

    // Update bookedCount di event secara atomik
    try {
      await eventRef.update({
        'bookedCount': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  static Future<void> cancelTicket(String ticketId, String? eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Pengguna tidak login');

    await FirebaseFirestore.instance.collection('tickets').doc(ticketId).update({
      'status': 'cancelled',
      'cancelledAt': Timestamp.now(),
    });

    if (eventId != null && eventId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('events').doc(eventId).update({
          'bookedCount': FieldValue.increment(-1),
        });
      } catch (_) {}
    }
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

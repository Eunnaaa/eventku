import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class AdminEventService {
  static final _ref = FirebaseFirestore.instance.collection('events');

  static Future<void> createEvent(EventModel event) async {
    await _ref.add(event.toMap());
  }

  static Future<void> updateEvent(EventModel event) async {
    await _ref.doc(event.id).update(event.toUpdateMap());
  }

  static Future<void> deleteEvent(String id) async {
    // 1. Ambil tiket yang terdaftar untuk event ini
    final ticketsSnap = await FirebaseFirestore.instance
        .collection('tickets')
        .where('eventId', isEqualTo: id)
        .get();

    // 2. Eksekusi batch write untuk menghapus event dan menandai tiket sebagai 'event_cancelled'
    final batch = FirebaseFirestore.instance.batch();
    batch.delete(_ref.doc(id));

    for (final doc in ticketsSnap.docs) {
      final status = doc.data()['status']?.toString();
      if (status == 'upcoming') {
        batch.update(doc.reference, {
          'status': 'event_cancelled',
          'cancelledAt': Timestamp.now(),
          'cancelReason': 'Event dibatalkan oleh panitia penyelenggara',
        });
      }
    }

    await batch.commit();
  }

  static Future<void> togglePublish(String id, bool value) async {
    await _ref.doc(id).update({'isPublished': value});
  }

  static Stream<List<EventModel>> getEvents() {
    return _ref
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map(EventModel.fromFirestore).toList(),
    );
  }
}

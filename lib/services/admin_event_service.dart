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

    // 2. Eksekusi batch write bersegmen (chunked) untuk menghindari batas 500 operasi Firestore
    final docsToUpdate = ticketsSnap.docs.where((doc) {
      final status = doc.data()['status']?.toString();
      return status == 'upcoming';
    }).toList();

    const chunkSize = 400;
    for (int i = 0; i < docsToUpdate.length; i += chunkSize) {
      final end = (i + chunkSize < docsToUpdate.length) ? i + chunkSize : docsToUpdate.length;
      final chunk = docsToUpdate.sublist(i, end);

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in chunk) {
        batch.update(doc.reference, {
          'status': 'event_cancelled',
          'cancelledAt': Timestamp.now(),
          'cancelReason': 'Event dibatalkan oleh panitia penyelenggara',
        });
      }
      await batch.commit();
    }

    // 3. Hapus dokumen event utama
    await _ref.doc(id).delete();
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

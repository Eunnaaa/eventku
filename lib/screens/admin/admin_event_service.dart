import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event_model.dart';

class AdminEventService {
  static final _ref = FirebaseFirestore.instance.collection('events');

  static Future<void> createEvent(EventModel event) async {
    await _ref.add(event.toMap());
  }

  static Future<void> updateEvent(EventModel event) async {
    await _ref.doc(event.id).update(event.toMap());
  }

  static Future<void> deleteEvent(String id) async {
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

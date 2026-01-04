import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';

class TicketService {
  static Future<void> bookEvent(EventModel event) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    await FirebaseFirestore.instance.collection('tickets').add({
      'userId': user.uid,
      'eventId': event.id,
      'title': event.title,
      'date': event.date,
      'time': event.time,
      'location': event.location,
      'status': 'upcoming',
      'createdAt': Timestamp.now(),
    });
  }
}

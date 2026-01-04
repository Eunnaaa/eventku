import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String category;
  final String date;
  final String time;
  final String location;
  final String description;
  final String image;
  final Timestamp createdAt;
  final bool isPublished;

  EventModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.image,
    required this.createdAt,
    required this.isPublished,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isPublished: data['isPublished'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'date': date,
      'time': time,
      'location': location,
      'description': description,
      'image': image,
      'createdAt': createdAt,
      'isPublished': isPublished,
    };
  }
}

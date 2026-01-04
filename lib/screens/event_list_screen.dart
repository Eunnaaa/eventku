import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      /// 🔥 APPBAR SESUAI TEMA
      appBar: AppBar(
        title: const Text(
          'All Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Column(
        children: [
          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search event...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 📋 EVENT LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .where('isPublished', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Terjadi kesalahan',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                /// 🔥 MAP & FILTER
                final events = snapshot.data!.docs
                    .map((e) => EventModel.fromFirestore(e))
                    .where((e) =>
                    e.title.toLowerCase().contains(search))
                    .toList();

                /// 🔥 SORT CLIENT SIDE (NO INDEX)
                events.sort(
                      (a, b) => b.createdAt.compareTo(a.createdAt),
                );

                if (events.isEmpty) {
                  return const Center(child: Text('Event tidak ditemukan'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: events.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 25),
                  itemBuilder: (context, i) {
                    return SizedBox(
                      height: 250, // 🔥 FIX CARD HEIGHT
                      child: EventCard(event: events[i]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import 'admin_event_service.dart';
import 'event_form_screen.dart';

class ManageEventScreen extends StatelessWidget {
  const ManageEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Events')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: AdminEventService.getEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!;
          if (events.isEmpty) {
            return const Center(child: Text('No events'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, i) {
              final event = events[i];
              return Card(
                child: ListTile(
                  title: Text(event.title),
                  subtitle: Text(event.location),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: event.isPublished,
                        onChanged: (v) {
                          AdminEventService.togglePublish(event.id, v);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventFormScreen(event: event),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          AdminEventService.deleteEvent(event.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

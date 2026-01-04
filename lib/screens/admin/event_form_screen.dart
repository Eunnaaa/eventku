import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event_model.dart';
import 'admin_event_service.dart';

class EventFormScreen extends StatefulWidget {
  final EventModel? event;
  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final title = TextEditingController();
  final category = TextEditingController();
  final date = TextEditingController();
  final time = TextEditingController();
  final location = TextEditingController();
  final description = TextEditingController();
  final image = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      title.text = widget.event!.title;
      category.text = widget.event!.category;
      date.text = widget.event!.date;
      time.text = widget.event!.time;
      location.text = widget.event!.location;
      description.text = widget.event!.description;
      image.text = widget.event!.image;
    }
  }

  Future<void> submit() async {
    final event = EventModel(
      id: widget.event?.id ?? '',
      title: title.text.trim(),
      category: category.text.trim(),
      date: date.text.trim(),
      time: time.text.trim(),
      location: location.text.trim(),
      description: description.text.trim(),
      image: image.text.trim(),
      createdAt: widget.event?.createdAt ?? Timestamp.now(),
      isPublished: widget.event?.isPublished ?? true,
    );

    if (widget.event == null) {
      await AdminEventService.createEvent(event);
    } else {
      await AdminEventService.updateEvent(event);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text(widget.event == null ? 'Create Event' : 'Edit Event')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _input(title, 'Title'),
            _input(category, 'Category'),
            _input(date, 'Date'),
            _input(time, 'Time'),
            _input(location, 'Location'),
            _input(description, 'Description'),
            _input(image, 'Image URL (imgbb)'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: submit,
              child: const Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

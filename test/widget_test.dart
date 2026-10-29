import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventku/models/event_model.dart';
import 'package:eventku/services/event_seed_service.dart';

void main() {
  group('EventModel Unit Tests & Timestamp Migration', () {
    test('EventModel initializes with Timestamp eventDate correctly', () {
      final now = Timestamp.now();
      final targetDate = Timestamp.fromDate(DateTime(2026, 11, 15));

      final event = EventModel(
        id: 'test-123',
        title: 'Flutter Developer Conference',
        category: 'Technology',
        date: '15 Nov 2026',
        eventDate: targetDate,
        time: '09:00',
        location: 'Jakarta Convention Center',
        description: 'Konferensi tahunan developer Flutter.',
        image: 'https://example.com/poster.jpg',
        createdAt: now,
        isPublished: true,
      );

      expect(event.id, 'test-123');
      expect(event.title, 'Flutter Developer Conference');
      expect(event.category, 'Technology');
      expect(event.eventDate, targetDate);
      expect(event.quota, 100);
      expect(event.bookedCount, 0);
      expect(event.isOnline, false);
      expect(event.benefits.length, 4);
    });

    test('EventModel.parseDate correctly parses textual dates into Timestamp', () {
      final timestamp = EventModel.parseDate(null, '15 Nov 2026');
      final dt = timestamp.toDate();

      expect(dt.year, 2026);
      expect(dt.month, 11);
      expect(dt.day, 15);
    });

    test('EventModel.formatDate converts DateTime to standard readable string', () {
      final dt = DateTime(2026, 12, 25);
      final formatted = EventModel.formatDate(dt);

      expect(formatted, '25 Dec 2026');
    });

    test('EventModel toMap includes native eventDate Timestamp and date string', () {
      final now = Timestamp.now();
      final targetDate = Timestamp.fromDate(DateTime(2026, 11, 20));

      final event = EventModel(
        id: 'ev-1',
        title: 'UI/UX Masterclass',
        category: 'Design',
        date: '20 Nov 2026',
        eventDate: targetDate,
        time: '13:00',
        location: 'Zoom Webinar',
        description: 'Belajar desain sistem.',
        image: 'https://example.com/ui.jpg',
        createdAt: now,
        isPublished: true,
        quota: 50,
        bookedCount: 15,
        speakerName: 'Sarah Connor',
        speakerRole: 'Lead Product Designer',
        isOnline: true,
      );

      final map = event.toMap();

      expect(map['title'], 'UI/UX Masterclass');
      expect(map['category'], 'Design');
      expect(map['date'], '20 Nov 2026');
      expect(map['eventDate'], targetDate);
      expect(map['quota'], 50);
      expect(map['bookedCount'], 15);
      expect(map['speakerName'], 'Sarah Connor');
      expect(map['isOnline'], true);
      expect(map['isPublished'], true);
    });

    test('EventSeedService provides rich event samples for all categories', () {
      final samples = EventSeedService.getSampleEvents();
      expect(samples.isNotEmpty, true);

      final categories = samples.map((e) => e.category).toSet();
      expect(categories.contains('Technology'), true);
      expect(categories.contains('Business'), true);
      expect(categories.contains('Health'), true);
      expect(categories.contains('Travel'), true);
      expect(categories.contains('Education'), true);

      for (final ev in samples) {
        expect(ev.title.isNotEmpty, true);
        expect(ev.image.startsWith('https://'), true);
        expect(ev.speakerName.isNotEmpty, true);
        expect(ev.benefits.isNotEmpty, true);
        expect(ev.eventDate.toDate().isAfter(DateTime(2026, 1, 1)), true);
      }
    });
  });
}

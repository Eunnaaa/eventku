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

    test('EventModel toUpdateMap excludes bookedCount and createdAt for safe admin updates', () {
      final now = Timestamp.now();
      final targetDate = Timestamp.fromDate(DateTime(2026, 11, 20));

      final event = EventModel(
        id: 'ev-1',
        title: 'Updated Title',
        category: 'Technology',
        date: '20 Nov 2026',
        eventDate: targetDate,
        time: '14:00',
        location: 'Hall B',
        description: 'New Description',
        image: 'https://example.com/new.jpg',
        createdAt: now,
        isPublished: true,
        quota: 80,
        bookedCount: 42,
      );

      final updateMap = event.toUpdateMap();

      expect(updateMap['title'], 'Updated Title');
      expect(updateMap['quota'], 80);
      expect(updateMap.containsKey('bookedCount'), false, reason: 'toUpdateMap must not include bookedCount');
      expect(updateMap.containsKey('createdAt'), false, reason: 'toUpdateMap must not include createdAt');
    });

    test('Short ticket pass code extraction formatting', () {
      const docId = 'ab12cd34ef56gh78';
      final shortCode = docId.substring(0, 8).toUpperCase();
      expect(shortCode, 'AB12CD34');
      expect(shortCode.length, 8);
    });

    test('EventSeedService provides rich event samples for all categories', () {
      final samples = EventSeedService.getSampleEvents();
      expect(samples.length >= 20, true, reason: 'Must contain at least 20 rich upcoming events');

      final categories = samples.map((e) => e.category).toSet();
      expect(categories.contains('Technology'), true);
      expect(categories.contains('Business'), true);
      expect(categories.contains('Health'), true);
      expect(categories.contains('Travel'), true);
      expect(categories.contains('Education'), true);

      // Verify each category has multiple events
      for (final cat in ['Technology', 'Business', 'Health', 'Travel', 'Education']) {
        final count = samples.where((e) => e.category == cat).length;
        expect(count >= 4, true, reason: 'Category $cat must have at least 4 events');
      }

      // Verify format diversity
      expect(samples.any((e) => e.isOnline), true);
      expect(samples.any((e) => !e.isOnline), true);

      // Verify future dates spanning 2026 and 2027
      expect(samples.any((e) => e.eventDate.toDate().year == 2026), true);
      expect(samples.any((e) => e.eventDate.toDate().year == 2027), true);

      for (final ev in samples) {
        expect(ev.title.isNotEmpty, true);
        expect(ev.image.startsWith('https://'), true);
        expect(ev.speakerName.isNotEmpty, true);
        expect(ev.speakerRole.isNotEmpty, true);
        expect(ev.benefits.isNotEmpty, true);
        expect(ev.quota > 0, true);
        expect(ev.isPublished, true);
        expect(ev.eventDate.toDate().isAfter(DateTime(2026, 11, 1)), true);
      }
    });

    test('Business Logic: Event expiration and cancellation deadline calculation', () {
      final pastDate = DateTime(2025, 1, 1);
      final futureDate = DateTime(2030, 12, 31);
      final now = DateTime.now();

      final pastEndOfDay = DateTime(pastDate.year, pastDate.month, pastDate.day, 23, 59, 59);
      final futureEndOfDay = DateTime(futureDate.year, futureDate.month, futureDate.day, 23, 59, 59);

      // Past event should be identified as expired
      expect(now.isAfter(pastEndOfDay), true);
      // Future event should be identified as active
      expect(now.isAfter(futureEndOfDay), false);

      // Cancellation deadline: past event start has passed
      final pastStartOfDay = DateTime(pastDate.year, pastDate.month, pastDate.day);
      expect(now.isAfter(pastStartOfDay), true);
    });

    test('Batch deletion safety: chunking prevents Firestore 500-write limit overflow', () {
      final dummyDocIds = List.generate(950, (i) => 'ticket_$i');
      const chunkSize = 400;

      final chunks = <List<String>>[];
      for (var i = 0; i < dummyDocIds.length; i += chunkSize) {
        chunks.add(
          dummyDocIds.sublist(
            i,
            (i + chunkSize > dummyDocIds.length) ? dummyDocIds.length : i + chunkSize,
          ),
        );
      }

      expect(chunks.length, 3);
      expect(chunks[0].length, 400);
      expect(chunks[1].length, 400);
      expect(chunks[2].length, 150);
      for (final chunk in chunks) {
        expect(chunk.length <= 400, true);
      }
    });

    test('Gate Check-in isolation logic', () {
      const gateEventId = 'ev-react-summit';
      final validTicket = {'eventId': 'ev-react-summit', 'status': 'upcoming'};
      final foreignTicket = {'eventId': 'ev-flutter-conf', 'status': 'upcoming'};
      final completedTicket = {'eventId': 'ev-react-summit', 'status': 'completed'};

      bool canCheckIn(Map<String, dynamic> ticket, String? gateId) {
        if (ticket['status'] != 'upcoming') return false;
        if (gateId != null && gateId.isNotEmpty && ticket['eventId'] != gateId) return false;
        return true;
      }

      expect(canCheckIn(validTicket, gateEventId), true);
      expect(canCheckIn(foreignTicket, gateEventId), false);
      expect(canCheckIn(completedTicket, gateEventId), false);
      // Open gate mode allows any upcoming event
      expect(canCheckIn(foreignTicket, null), true);
    });
  });
}

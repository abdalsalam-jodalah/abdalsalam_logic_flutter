// lib/src/calendar/calendar_service.dart
import '../core/interfaces/service_interface.dart';

abstract class CalendarService extends ServiceInterface {
  Future<void> addEvent({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
    String? location,
  });
  Future<List<Map<String, dynamic>>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<void> updateEvent(String eventId, Map<String, dynamic> updates);
  Future<void> deleteEvent(String eventId);
}


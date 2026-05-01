import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:blud_flutter/providers/event_provider.dart';
import 'package:blud_flutter/services/event_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

class MockEventService extends Mock implements EventService {}

void main() {
  late EventProvider eventProvider;
  late MockEventService mockEventService;

  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    await Hive.openBox('api_cache');
  });

  setUp(() {
    mockEventService = MockEventService();
    eventProvider = EventProvider(mockEventService);
  });

  group('EventProvider Tests', () {
    test('fetchJadwal success should update events list', () async {
      // Arrange
      final responseData = {
        'data': [
          {'id': 1, 'name': 'Event 1', 'date': '2024-05-01'}
        ]
      };

      when(() => mockEventService.getJadwal()).thenAnswer(
        (_) async => Response(
          data: responseData,
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      // Act
      await eventProvider.fetchJadwal();

      // Assert
      expect(eventProvider.events.length, 1);
      expect(eventProvider.events[0].name, 'Event 1');
    });
  });
}

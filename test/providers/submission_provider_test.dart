import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:blud_flutter/providers/submission_provider.dart';
import 'package:blud_flutter/services/submission_service.dart';



class MockSubmissionService extends Mock implements SubmissionService {}

void main() {
  late SubmissionProvider submissionProvider;
  late MockSubmissionService mockSubmissionService;

  setUp(() {
    mockSubmissionService = MockSubmissionService();
    submissionProvider = SubmissionProvider(mockSubmissionService);
    registerFallbackValue(FormData());
  });

  group('SubmissionProvider Tests', () {
    test('fetchLocationOptions success should update locationOptions', () async {
      // Arrange
      final responseData = {
        'data': [
          {'id': 1, 'name': 'Lokasi A', 'slug': 'lokasi-a'}
        ]
      };

      when(() => mockSubmissionService.getLocations()).thenAnswer(
        (_) async => Response(
          data: responseData,
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      // Act
      await submissionProvider.fetchLocationOptions();

      // Assert
      expect(submissionProvider.locationOptions.length, 1);
      expect(submissionProvider.locationOptions[0].name, 'Lokasi A');
    });

    test('submitBooking success should return true', () async {
      // Arrange
      when(() => mockSubmissionService.submitRequest(any())).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );
      when(() => mockSubmissionService.getHistory()).thenAnswer(
        (_) async => Response(
          data: {'data': []},
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      final result = await submissionProvider.submitBooking(FormData.fromMap({'test': 'data'}));

      // Assert
      expect(result, true);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:blud_flutter/providers/content_provider.dart';
import 'package:blud_flutter/services/content_service.dart';
import 'package:blud_flutter/core/services/cache_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

class MockContentService extends Mock implements ContentService {}
class MockBox extends Mock implements Box {}

void main() {
  late ContentProvider contentProvider;
  late MockContentService mockContentService;

  setUpAll(() async {
    // Setup Hive for testing
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    await Hive.openBox('api_cache');
  });

  setUp(() {
    mockContentService = MockContentService();
    contentProvider = ContentProvider(mockContentService);
  });

  group('ContentProvider Tests', () {
    test('fetchHomeData success should update featuredContents', () async {
      // Arrange
      final responseData = {
        'data': {
          'contents': [
            {'id': 1, 'name': 'Destinasi 1', 'slug': 'dest-1', 'image': 'img.jpg'}
          ]
        }
      };

      when(() => mockContentService.getHomeData()).thenAnswer(
        (_) async => Response(
          data: responseData,
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      // Act
      await contentProvider.fetchHomeData();

      // Assert
      expect(contentProvider.featuredContents.length, 1);
      expect(contentProvider.featuredContents[0].name, 'Destinasi 1');
      expect(contentProvider.isLoading, false);
    });

    test('fetchHomeData failure should set error message', () async {
      // Arrange
      when(() => mockContentService.getHomeData()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      // Act
      await contentProvider.fetchHomeData();

      // Assert
      expect(contentProvider.errorMessage, contains('Gagal memuat data beranda'));
    });
  });
}

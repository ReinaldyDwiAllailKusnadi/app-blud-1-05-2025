import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:blud_flutter/providers/auth_provider.dart';
import 'package:blud_flutter/services/auth_service.dart';
import 'package:blud_flutter/core/network/dio_client.dart';

class MockAuthService extends Mock implements AuthService {}
class MockDioClient extends Mock implements DioClient {}

void main() {
  late AuthProvider authProvider;
  late MockAuthService mockAuthService;
  late MockDioClient mockDioClient;

  setUp(() {
    mockAuthService = MockAuthService();
    mockDioClient = MockDioClient();
    authProvider = AuthProvider(mockAuthService, mockDioClient);
  });

  group('AuthProvider Tests', () {
    test('Initial state should be logged out', () {
      expect(authProvider.user, null);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.isLoading, false);
    });

    test('Login success should update user and isAuthenticated', () async {
      // Arrange
      final userData = {'id': 1, 'name': 'Test User', 'email': 'test@example.com'};
      final responseData = {
        'data': {
          'token': 'fake_token',
          'user': userData,
        }
      };

      when(() => mockAuthService.login(any(), any())).thenAnswer(
        (_) async => Response(
          data: responseData,
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );
      when(() => mockDioClient.saveToken(any())).thenAnswer((_) async => {});

      // Act
      final result = await authProvider.login('test@example.com', 'password');

      // Assert
      expect(result, true);
      expect(authProvider.user, isNotNull);
      expect(authProvider.user!.name, 'Test User');
      expect(authProvider.isAuthenticated, true);
      verify(() => mockDioClient.saveToken('fake_token')).called(1);
    });

    test('Login failure should set error message', () async {
      // Arrange
      when(() => mockAuthService.login(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            data: {'message': 'Invalid credentials'},
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await authProvider.login('test@example.com', 'wrong');

      // Assert
      expect(result, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.errorMessage, 'Invalid credentials');
    });
  });
}

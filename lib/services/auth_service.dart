import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  Future<Response> login(String email, String password) async {
    return await _dioClient.post('/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> loginWithGoogleAPI(String idToken) async {
    return await _dioClient.post('/auth/google', data: {
      'id_token': idToken,
    });
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _dioClient.post('/register', data: data);
  }

  Future<Response> getProfile() async {
    return await _dioClient.get('/profile');
  }

  Future<Response> logout() async {
    return await _dioClient.post('/logout');
  }

  Future<Response> updateProfile({
    required String name,
    required String username,
    required String phone,
    required String email,
  }) async {
    return await _dioClient.put('/profile', data: {
      'name': name,
      'username': username,
      'phone': phone,
      'email': email,
    });
  }

  Future<Response> forgotPassword(String email) async {
    return await _dioClient.post('/forgot-password', data: {
      'email': email,
    });
  }

  Future<Response> verifyResetCode({
    required String email,
    required String code,
  }) async {
    return await _dioClient.post('/verify-reset-code', data: {
      'email': email,
      'code': code,
    });
  }

  Future<Response> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await _dioClient.post('/reset-password', data: {
      'email': email,
      'code': code,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }
}

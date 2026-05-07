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
    return await _dioClient.post('/profile/update', data: {
      'name': name,
      'username': username,
      'phone': phone,
      'email': email,
    });
  }
}

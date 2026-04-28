import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/services/dio_client.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  final DioClient _dio = DioClient();

  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;

  /// Check if user already has a saved token
  Future<bool> checkAuth() async {
    final token = await _dio.getToken();
    if (token != null) {
      try {
        final response = await _dio.get('/profile');
        if (response.data['success'] == true) {
          _user = UserModel.fromJson(response.data['data']);
          _isLoggedIn = true;
          notifyListeners();
          return true;
        }
      } catch (_) {
        await _dio.deleteToken();
      }
    }
    _isLoggedIn = false;
    notifyListeners();
    return false;
  }

  /// Login with email & password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success'] == true) {
        await _dio.saveToken(response.data['data']['token']);
        _user = UserModel.fromJson(response.data['data']['user']);
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = _extractError(e);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Register new user
  Future<bool> register({
    required String name,
    String? phone,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.post('/register', data: {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      if (response.data['success'] == true) {
        await _dio.saveToken(response.data['data']['token']);
        _user = UserModel.fromJson(response.data['data']['user']);
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = _extractError(e);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Login with Google
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account == null) {
        _errorMessage = 'Login Google dibatalkan.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      final response = await _dio.post('/auth/google', data: {
        'id_token': auth.accessToken,
      });

      if (response.data['success'] == true) {
        await _dio.saveToken(response.data['data']['token']);
        _user = UserModel.fromJson(response.data['data']['user']);
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = _extractError(e);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {}
    await _dio.deleteToken();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  /// Update profile
  Future<bool> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{
        'name': name,
        'email': email,
        'phone': phone,
      };
      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }

      final response = await _dio.post('/profile/update', data: data);

      if (response.data['success'] == true) {
        _user = UserModel.fromJson(response.data['data']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = _extractError(e);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _extractError(dynamic e) {
    if (e is Exception) {
      try {
        final dioError = e as dynamic;
        if (dioError.response?.data != null) {
          final data = dioError.response.data;
          if (data is Map && data['message'] != null) {
            return data['message'];
          }
        }
      } catch (_) {}
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}

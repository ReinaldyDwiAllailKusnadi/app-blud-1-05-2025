import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/network/dio_client.dart';
import '../core/providers/base_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends BaseProvider {
  final AuthService _authService;
  final DioClient _dioClient;

  UserModel? _user;
  bool _isLoginLoading = false;
  bool _isGoogleLoading = false;

  AuthProvider(this._authService, this._dioClient);

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoggedIn => _user != null;
  bool get isLoginLoading => _isLoginLoading;
  bool get isGoogleLoading => _isGoogleLoading;

  Future<bool> login(String email, String password) async {
    _isLoginLoading = true;
    notifyListeners();
    setError(null);
    try {
      final response = await _authService.login(email, password);
      final token = response.data['data']['token'];
      final userData = response.data['data']['user'];

      await _dioClient.saveToken(token);
      _user = UserModel.fromJson(userData);
      
      _isLoginLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      handleDioError(e, defaultMessage: 'Login gagal. Periksa kembali email dan password Anda.');
      _isLoginLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    setLoading(true);
    setError(null);
    try {
      final response = await _authService.register(data);
      
      // Cek apakah response berisi token (auto-login)
      final responseData = response.data['data'];
      if (responseData != null && responseData['token'] != null) {
        final token = responseData['token'];
        final userData = responseData['user'];

        await _dioClient.saveToken(token);
        _user = UserModel.fromJson(userData);
      } else {
        // Jika tidak ada token, berarti registrasi sukses tapi harus login manual
        _user = null;
      }

      setLoading(false);
      return true;
    } catch (e) {
      handleDioError(e, defaultMessage: 'Registrasi gagal. Silakan coba lagi.');
      setLoading(false);
      return false;
    }
  }

  Future<void> getProfile() async {
    setLoading(true);
    try {
      final response = await _authService.getProfile();
      _user = UserModel.fromJson(response.data['data']);
    } catch (e) {
      _user = null;
    }
    setLoading(false);
  }

  Future<void> logout() async {
    setLoading(true);
    try {
      // Panggil logout API
      await _authService.logout();
    } catch (e) {
      // Abaikan error API logout agar logout lokal tetap berhasil
    } finally {
      // Sign out dari Google jika ada
      try {
        await GoogleSignIn().signOut();
      } catch (e) {
        // Abaikan error sign out Google
      }

      await _dioClient.deleteToken();
      _user = null;
      setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> checkAuth() async {
    final token = await _dioClient.getToken();
    if (token == null) return false;

    try {
      final response = await _authService.getProfile();
      _user = UserModel.fromJson(response.data['data']);
      notifyListeners();
      return true;
    } catch (e) {
      await _dioClient.deleteToken();
      _user = null;
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isGoogleLoading = true;
    notifyListeners();
    setError(null);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '257992216746-1pm552pmrsd83o5n0rdqqr6g5k4j0ur5.apps.googleusercontent.com',
      );

      // Mulai proses sign in Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User membatalkan login
        _isGoogleLoading = false;
        notifyListeners();
        return false;
      }

      // Ambil detail autentikasi (token)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        setError('Gagal mendapatkan ID Token dari Google.');
        _isGoogleLoading = false;
        notifyListeners();
        return false;
      }

      // Kirim ID Token ke backend Laravel
      final response = await _authService.loginWithGoogleAPI(googleAuth.idToken!);
      
      final token = response.data['data']['token'];
      final userData = response.data['data']['user'];

      // Simpan token Sanctum dan set user
      await _dioClient.saveToken(token);
      _user = UserModel.fromJson(userData);

      _isGoogleLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Google Login Error: $e');
      if (e is DioException) {
        handleDioError(e, defaultMessage: 'Gagal login ke server BLUD. Silakan coba lagi.');
      } else {
        setError('Gagal login Google: $e');
      }
      _isGoogleLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String username,
    required String phone,
    required String email,
  }) async {
    setLoading(true);
    setError(null);
    try {
      final response = await _authService.updateProfile(
        name: name,
        username: username,
        phone: phone,
        email: email,
      );

      final userData = response.data['data'];
      _user = UserModel.fromJson(userData);
      
      setLoading(false);
      return true;
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memperbarui profil. Silakan coba lagi.');
      setLoading(false);
      return false;
    }
  }
}

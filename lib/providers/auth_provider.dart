import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/network/dio_client.dart';
import '../core/providers/base_provider.dart';

class AuthProvider extends BaseProvider {
  final AuthService _authService;
  final DioClient _dioClient;

  UserModel? _user;

  AuthProvider(this._authService, this._dioClient);

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    setLoading(true);
    setError(null);
    try {
      final response = await _authService.login(email, password);
      final token = response.data['data']['token'];
      final userData = response.data['data']['user'];

      await _dioClient.saveToken(token);
      _user = UserModel.fromJson(userData);
      
      setLoading(false);
      return true;
    } catch (e) {
      handleDioError(e, defaultMessage: 'Login gagal. Periksa kembali email dan password Anda.');
      setLoading(false);
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    setLoading(true);
    setError(null);
    try {
      final response = await _authService.register(data);
      final token = response.data['data']['token'];
      final userData = response.data['data']['user'];

      await _dioClient.saveToken(token);
      _user = UserModel.fromJson(userData);

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
      await _authService.logout();
    } catch (e) {
      // Abaikan error API logout agar logout lokal tetap berhasil
    } finally {
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
    setError('Login Google belum tersedia');
    return false;
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

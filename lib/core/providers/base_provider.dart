import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Utility to handle common Dio errors and parse messages
  void handleDioError(dynamic e, {String? defaultMessage}) {
    if (e is DioException && e.response != null) {
      _errorMessage = e.response?.data['message'] ?? defaultMessage ?? 'Terjadi kesalahan pada server';
    } else {
      _errorMessage = 'Gagal terhubung ke server. Periksa koneksi Anda.';
    }
    notifyListeners();
  }
}

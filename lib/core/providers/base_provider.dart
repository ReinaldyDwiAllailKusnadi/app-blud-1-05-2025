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
    if (e is DioException) {
      if (e.response != null) {
        final data = e.response?.data;
        final statusCode = e.response?.statusCode;

        if (statusCode == 401) {
          _errorMessage = 'Sesi login berakhir. Silakan login kembali.';
        } else if (statusCode == 413) {
          _errorMessage = 'Ukuran file terlalu besar. Maksimal 5MB.';
        } else if (statusCode == 422 && data is Map) {
          // Extract validation error
          if (data['message'] != null) {
            _errorMessage = data['message'].toString();
          } else if (data['errors'] is Map) {
            final errors = data['errors'] as Map;
            if (errors.isNotEmpty) {
              final first = errors.values.first;
              if (first is List && first.isNotEmpty) {
                _errorMessage = first.first.toString();
              } else {
                _errorMessage = first.toString();
              }
            }
          } else {
            _errorMessage = defaultMessage ?? 'Data yang dikirim tidak valid.';
          }
        } else if (statusCode == 500) {
          _errorMessage = 'Terjadi kesalahan pada server (500).';
        } else {
          _errorMessage = data is Map && data['message'] != null 
              ? data['message'].toString() 
              : defaultMessage ?? 'Terjadi kesalahan pada server ($statusCode)';
        }
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        _errorMessage = 'Server membutuhkan waktu terlalu lama. Coba lagi atau gunakan file yang lebih kecil.';
      } else {
        _errorMessage = 'Gagal terhubung ke server. Periksa koneksi Anda.';
      }
    } else {
      _errorMessage = defaultMessage ?? e.toString();
    }
    notifyListeners();
  }
}

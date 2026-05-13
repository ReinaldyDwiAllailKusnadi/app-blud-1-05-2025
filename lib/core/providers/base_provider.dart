import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, List<String>> _errors = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, List<String>> get fieldErrors => _errors;

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
    _errors = {};
    notifyListeners();
  }

  /// Utility to handle common Dio errors and parse messages
  void handleDioError(dynamic e, {String? defaultMessage}) {
    _errors = {};
    if (e is DioException) {
      if (e.response != null) {
        final data = e.response?.data;
        final statusCode = e.response?.statusCode;

        if (statusCode == 401) {
          _errorMessage = 'Sesi login berakhir. Silakan login kembali.';
        } else if (statusCode == 413) {
          _errorMessage = 'Ukuran file terlalu besar. Maksimal 5MB.';
        } else if (statusCode == 422 && data is Map) {
          // Extract validation errors
          if (data['errors'] is Map) {
            final rawErrors = data['errors'] as Map;
            _errors = rawErrors.map((key, value) {
              if (value is List) {
                return MapEntry(key.toString(), value.map((v) => v.toString()).toList());
              }
              return MapEntry(key.toString(), [value.toString()]);
            });

            // Set main error message to the first validation error
            if (_errors.isNotEmpty) {
              _errorMessage = _errors.values.first.first;
            } else {
              _errorMessage = data['message']?.toString() ?? defaultMessage ?? 'Validasi gagal.';
            }
          } else {
            _errorMessage = data['message']?.toString() ?? defaultMessage ?? 'Data yang dikirim tidak valid.';
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

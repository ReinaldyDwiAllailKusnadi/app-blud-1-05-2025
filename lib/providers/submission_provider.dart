import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../models/content_model.dart';
import '../models/submission_model.dart';
import '../services/submission_service.dart';
import '../core/providers/base_provider.dart';
import '../core/network/dio_client.dart';
import '../core/constants/constants.dart';

class SubmissionProvider extends BaseProvider {
  final SubmissionService _submissionService;
  final DioClient _dioClient;

  List<ContentModel> _locationOptions = [];
  List<SubmissionModel> _history = [];

  SubmissionProvider(this._submissionService, this._dioClient);

  List<ContentModel> get locationOptions => _locationOptions;
  List<SubmissionModel> get history => _history;

  Future<void> fetchLocationOptions() async {
    setLoading(true);
    setError(null);

    try {
      final response = await _submissionService.getLocations();
      final List data = response.data['data'] ?? [];
      _locationOptions = data.map((e) => ContentModel.fromJson(e)).toList();
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memuat opsi lokasi');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchHistory() async {
    setLoading(true);
    setError(null);

    try {
      final token = await _dioClient.getToken();
      debugPrint('--- Submission History Debug ---');
      debugPrint('Base URL: ${ApiConstants.baseUrl}');
      debugPrint('Token exists: ${token != null}');
      if (token != null && token.length > 20) {
        debugPrint('Token starts with: ${token.substring(0, 15)}...');
      }

      final response = await _submissionService.getHistory();
      final data = response.data;
      debugPrint('Full API Response: $data');
      
      List rawList = [];

      if (data is Map) {
        if (data['debug'] != null) {
          debugPrint('Backend Debug: ${data['debug']}');
        }
        
        if (data['data'] is List) {
          rawList = data['data'];
        } else if (data['data'] is Map && data['data']['submissions'] is List) {
          rawList = data['data']['submissions'];
        } else if (data['history'] is List) {
          rawList = data['history'];
        } else if (data['data'] is Map && data['data']['history'] is List) {
          rawList = data['data']['history'];
        }
      } else if (data is List) {
        rawList = data;
      }

      debugPrint('Parsed rawList length: ${rawList.length}');

      _history = rawList
          .whereType<Map>()
          .map((item) {
            try {
              final model = SubmissionModel.fromJson(Map<String, dynamic>.from(item));
              return model;
            } catch (e) {
              debugPrint('Error parsing SubmissionModel: $e');
              debugPrint('Problematic item: $item');
              return null;
            }
          })
          .whereType<SubmissionModel>()
          .toList();
          
      debugPrint('Final history length: ${_history.length}');
      debugPrint('---------------------------------');
    } catch (e) {
      debugPrint('Error in fetchHistory: $e');
      handleDioError(e, defaultMessage: 'Gagal memuat riwayat pengajuan');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> submitBooking(FormData formData) async {
    setLoading(true);
    setError(null);

    debugPrint('--- Submitting Booking ---');
    debugPrint('Base URL: ${ApiConstants.baseUrl}');
    debugPrint('Endpoint: /submission');
    
    // Log non-file fields
    for (var field in formData.fields) {
      debugPrint('Field: ${field.key} = ${field.value}');
    }
    
    // Log files
    for (var file in formData.files) {
      debugPrint('File Key: ${file.key}, Filename: ${file.value.filename}, Length: ${file.value.length}');
    }

    try {
      final token = await _dioClient.getToken();
      debugPrint('Auth Token Exists: ${token != null}');
      
      final response = await _submissionService.submitRequest(formData);
      debugPrint('Submission Success Response: ${response.data}');
      
      if (response.data['success'] == true) {
        await fetchHistory();
        setLoading(false);
        return true;
      } else {
        setError(response.data['message'] ?? 'Gagal mengirim pengajuan.');
        setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('--- Submission Error ---');
      if (e is DioException) {
        debugPrint('Status Code: ${e.response?.statusCode}');
        debugPrint('Response Data: ${e.response?.data}');
        debugPrint('Error Type: ${e.type}');
        debugPrint('Error Message: ${e.message}');
      } else {
        debugPrint('Unknown Error: $e');
      }
      handleDioError(e, defaultMessage: 'Gagal mengirim pengajuan.');
      setLoading(false);
      return false;
    }
  }

  /// Helper to convert PlatformFile to MultipartFile, supporting both Mobile and Web
  static Future<MultipartFile?> multipartFromPickedFile(PlatformFile? file) async {
    if (file == null) return null;

    if (kIsWeb) {
      if (file.bytes != null) {
        return MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        );
      }
    } else {
      if (file.path != null) {
        return await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        );
      }
    }

    return null;
  }
}

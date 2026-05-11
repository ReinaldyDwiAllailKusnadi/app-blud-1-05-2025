import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../models/content_model.dart';
import '../models/submission_model.dart';
import '../services/submission_service.dart';
import '../core/providers/base_provider.dart';
import '../core/network/dio_client.dart';

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


      final response = await _submissionService.getHistory();
      final data = response.data;
      
      List rawList = [];

      if (data is Map) {
        
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



    try {

      
      final response = await _submissionService.submitRequest(formData);

      
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

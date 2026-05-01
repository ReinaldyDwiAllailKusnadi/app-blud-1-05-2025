import 'package:dio/dio.dart';
import '../models/content_model.dart';
import '../models/submission_model.dart';
import '../services/submission_service.dart';
import '../core/providers/base_provider.dart';

class SubmissionProvider extends BaseProvider {
  final SubmissionService _submissionService;

  List<ContentModel> _locationOptions = [];
  List<SubmissionModel> _history = [];

  SubmissionProvider(this._submissionService);

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
      final List data = response.data['data'] ?? [];
      _history = data.map((e) => SubmissionModel.fromJson(e)).toList();
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memuat riwayat pengajuan');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> submitBooking(Map<String, dynamic> data) async {
    setLoading(true);
    setError(null);

    try {
      final formData = FormData.fromMap(data);
      await _submissionService.submitRequest(formData);
      await fetchHistory();
      setLoading(false);
      return true;
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal mengirim pengajuan.');
      setLoading(false);
      return false;
    }
  }
}

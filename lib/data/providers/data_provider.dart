import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/models.dart';
import '../../core/providers/base_provider.dart';

class DataProvider extends BaseProvider {
  final DioClient _dio = DioClient();

  List<ContentModel> _contents = [];
  List<NewsModel> _news = [];
  ContentModel? _selectedContent;
  List<ContentFeatureModel> _prices = [];
  List<ContentFeatureModel> _facilities = [];
  List<JadwalBulanModel> _jadwalBulan = [];
  ContentModel? _jadwalContent;
  List<EventModel> _monthEvents = [];
  List<SubmissionModel> _submissions = [];
  List<ContentModel> _locationOptions = [];

  List<ContentModel> get contents => _contents;
  List<NewsModel> get news => _news;
  ContentModel? get selectedContent => _selectedContent;
  List<ContentFeatureModel> get prices => _prices;
  List<ContentFeatureModel> get facilities => _facilities;
  List<JadwalBulanModel> get jadwalBulan => _jadwalBulan;
  ContentModel? get jadwalContent => _jadwalContent;
  List<EventModel> get monthEvents => _monthEvents;
  List<SubmissionModel> get submissions => _submissions;
  List<ContentModel> get locationOptions => _locationOptions;

  Future<void> fetchHome() async {
    setLoading(true);
    setError(null);
    try {
      final response = await _dio.get('/home');
      if (response.data['success'] == true) {
        _contents = (response.data['data']['contents'] as List)
            .map((e) => ContentModel.fromJson(e))
            .toList();
        _news = (response.data['data']['news'] as List)
            .map((e) => NewsModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memuat data beranda.');
    }
    setLoading(false);
  }

  Future<void> fetchWisata() async {
    setLoading(true);
    setError(null);
    try {
      final response = await _dio.get('/wisata');
      if (response.data['success'] == true) {
        _contents = (response.data['data'] as List)
            .map((e) => ContentModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memuat data wisata.');
    }
    setLoading(false);
  }

  Future<void> fetchWisataDetail(String slug) async {
    setLoading(true);
    setError(null);
    try {
      final response = await _dio.get('/wisata/$slug');
      if (response.data['success'] == true) {
        _selectedContent = ContentModel.fromJson(response.data['data']);
      }
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memuat detail wisata.');
    }
    setLoading(false);
  }

  Future<void> fetchFasilitas(String slug) async {
    setLoading(true);
    setError(null);
    try {
      final response = await _dio.get('/fasilitas/$slug');
      if (response.data['success'] == true) {
        _selectedContent =
            ContentModel.fromJson(response.data['data']['content']);
        _prices = (response.data['data']['prices'] as List)
            .map((e) => ContentFeatureModel.fromJson(e))
            .toList();
        _facilities = (response.data['data']['facilities'] as List)
            .map((e) => ContentFeatureModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memuat fasilitas.');
    }
    setLoading(false);
  }

  Future<void> fetchJadwalByLocation(String slug) async {
    setLoading(true);
    setError(null);
    try {
      final response = await _dio.get('/booking/$slug');
      if (response.data['success'] == true) {
        _jadwalContent =
            ContentModel.fromJson(response.data['data']['content']);
        _jadwalBulan = (response.data['data']['jadwal'] as List)
            .map((e) => JadwalBulanModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memuat jadwal.');
    }
    setLoading(false);
  }

  Future<void> fetchJadwalByMonth(String slug, String bulan) async {
    setLoading(true);
    setError(null);
    try {
      final response = await _dio.get('/booking/$slug/$bulan');
      if (response.data['success'] == true) {
        _monthEvents = (response.data['data']['events'] as List)
            .map((e) => EventModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memuat detail jadwal.');
    }
    setLoading(false);
  }

  Future<void> fetchHistory() async {
    setLoading(true);
    setError(null);
    try {
      final response = await _dio.get('/history');
      if (response.data['success'] == true) {
        _submissions = (response.data['data'] as List)
            .map((e) => SubmissionModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memuat riwayat.');
    }
    setLoading(false);
  }

  Future<void> fetchLocationOptions() async {
    try {
      final response = await _dio.get('/submission/locations');
      if (response.data['success'] == true) {
        _locationOptions = (response.data['data'] as List)
            .map((e) => ContentModel.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> submitBooking(Map<String, dynamic> formData) async {
    setLoading(true);
    setError(null);
    try {
      final data = FormData.fromMap(formData);
      final response = await _dio.postMultipart('/submission', data: data);
      if (response.data['success'] == true) {
        setLoading(false);
        return true;
      } else {
        setError(response.data['message']);
      }
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal mengirim pengajuan.');
    }
    setLoading(false);
    return false;
  }
}

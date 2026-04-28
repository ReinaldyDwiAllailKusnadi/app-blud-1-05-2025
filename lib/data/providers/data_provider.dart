import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/services/dio_client.dart';
import '../models/models.dart';

class DataProvider extends ChangeNotifier {
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
  bool _isLoading = false;
  String? _errorMessage;

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
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchHome() async {
    _isLoading = true;
    notifyListeners();
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
      _errorMessage = 'Gagal memuat data beranda.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchWisata() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _dio.get('/wisata');
      if (response.data['success'] == true) {
        _contents = (response.data['data'] as List)
            .map((e) => ContentModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat data wisata.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchWisataDetail(String slug) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _dio.get('/wisata/$slug');
      if (response.data['success'] == true) {
        _selectedContent = ContentModel.fromJson(response.data['data']);
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat detail wisata.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFasilitas(String slug) async {
    _isLoading = true;
    notifyListeners();
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
      _errorMessage = 'Gagal memuat fasilitas.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchJadwalByLocation(String slug) async {
    _isLoading = true;
    notifyListeners();
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
      _errorMessage = 'Gagal memuat jadwal.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchJadwalByMonth(String slug, String bulan) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _dio.get('/booking/$slug/$bulan');
      if (response.data['success'] == true) {
        _monthEvents = (response.data['data']['events'] as List)
            .map((e) => EventModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat detail jadwal.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _dio.get('/history');
      if (response.data['success'] == true) {
        _submissions = (response.data['data'] as List)
            .map((e) => SubmissionModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat riwayat.';
    }
    _isLoading = false;
    notifyListeners();
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = FormData.fromMap(formData);
      final response = await _dio.postMultipart('/submission', data: data);
      if (response.data['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'];
      }
    } catch (e) {
      _errorMessage = 'Gagal mengirim pengajuan.';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          _errorMessage = data['message'];
        }
      }
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

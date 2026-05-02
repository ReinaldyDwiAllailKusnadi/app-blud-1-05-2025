import 'package:dio/dio.dart';
import '../models/content_model.dart';
import '../services/content_service.dart';
import '../core/services/cache_service.dart';
import '../core/providers/base_provider.dart';

class ContentProvider extends BaseProvider {
  final ContentService _contentService;

  List<ContentModel> _contents = [];
  List<ContentModel> _featuredContents = [];

  ContentProvider(this._contentService) {
    _init();
  }

  Future<void> _init() async {
    try {
      _loadFromCache();
    } catch (e) {
      // Abaikan error cache agar aplikasi tetap jalan
    }
  }

  void _loadFromCache() {
    try {
      final cachedHome = CacheService.get('home_data');
      if (cachedHome != null && cachedHome is Map) {
        final List data = (cachedHome['contents'] as List?) ?? [];
        _featuredContents = data
            .whereType<Map>()
            .map((e) => ContentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      final cachedWisata = CacheService.get('wisata_data');
      if (cachedWisata != null) {
        final List data = (cachedWisata as List?) ?? [];
        _contents = data
            .whereType<Map>()
            .map((e) => ContentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      // Jika cache corrupt, hapus atau abaikan
      CacheService.save('home_data', null);
      CacheService.save('wisata_data', null);
    }
  }

  List<ContentModel> get contents => _contents;
  List<ContentModel> get featuredContents => _featuredContents;

  Future<void> fetchHomeData() async {
    setLoading(true);
    setError(null);

    try {
      final response = await _contentService.getHomeData();
      final data = response.data;
      List rawList = [];

      if (data is Map && data['data'] is Map && data['data']['contents'] is List) {
        rawList = data['data']['contents'];
      }

      _featuredContents = rawList
          .whereType<Map>()
          .map((e) => ContentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      
      if (data is Map && data['data'] != null) {
        await CacheService.save('home_data', data['data']);
      }
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memuat data beranda');
      if (_featuredContents.isEmpty) _loadFromCache();
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchAllWisata() async {
    setLoading(true);
    setError(null);

    try {
      final response = await _contentService.getAllWisata();
      final data = response.data;
      List rawList = [];

      if (data is Map && data['data'] is List) {
        rawList = data['data'];
      }

      _contents = rawList
          .whereType<Map>()
          .map((e) => ContentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (data is Map && data['data'] != null) {
        await CacheService.save('wisata_data', data['data']);
      }
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memuat daftar wisata');
      if (_contents.isEmpty) _loadFromCache();
    } finally {
      setLoading(false);
    }
  }

  List<ContentModel> searchContents(String query) {
    if (query.isEmpty) return _contents;
    return _contents.where((element) => 
      element.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<ContentModel?> fetchWisataDetail(String slug) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _contentService.getWisataDetail(slug);
      final data = response.data['data'];
      if (data is Map) {
        return ContentModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memuat detail wisata');
      return null;
    } finally {
      setLoading(false);
    }
  }
}

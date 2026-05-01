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
    _loadFromCache();
  }

  void _loadFromCache() {
    final cachedHome = CacheService.get('home_data');
    if (cachedHome != null) {
      final List data = cachedHome['contents'] ?? [];
      _featuredContents = data.map((e) => ContentModel.fromJson(e)).toList();
    }

    final cachedWisata = CacheService.get('wisata_data');
    if (cachedWisata != null) {
      final List data = cachedWisata ?? [];
      _contents = data.map((e) => ContentModel.fromJson(e)).toList();
    }
  }

  List<ContentModel> get contents => _contents;
  List<ContentModel> get featuredContents => _featuredContents;

  Future<void> fetchHomeData() async {
    setLoading(true);
    setError(null);

    try {
      final response = await _contentService.getHomeData();
      final List data = response.data['data']['contents'] ?? [];
      _featuredContents = data.map((e) => ContentModel.fromJson(e)).toList();
      
      await CacheService.save('home_data', response.data['data']);
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
      final List data = response.data['data'] ?? [];
      _contents = data.map((e) => ContentModel.fromJson(e)).toList();

      await CacheService.save('wisata_data', response.data['data']);
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
      return ContentModel.fromJson(response.data['data']);
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memuat detail wisata');
      return null;
    } finally {
      setLoading(false);
    }
  }
}

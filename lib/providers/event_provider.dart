import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../core/services/cache_service.dart';
import '../core/providers/base_provider.dart';

class EventProvider extends BaseProvider {
  final EventService _eventService;

  List<EventModel> _events = [];

  EventProvider(this._eventService) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Tunggu sebentar agar Hive benar-benar siap (opsional tapi aman)
      _loadFromCache();
      fetchJadwal();
    } catch (e) {
      debugPrint('Error initializing EventProvider: $e');
    }
  }

  void _loadFromCache() {
    try {
      final cached = CacheService.get('event_data');
      if (cached != null) {
        // Gunakan pengecekan tipe yang lebih ketat untuk Web/JS
        final List rawData = cached is List ? cached : [];
        _events = rawData
            .whereType<Map>()
            .map((e) => EventModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading event cache: $e');
      CacheService.save('event_data', null);
    }
  }

  List<EventModel> get events => _events;

  Future<void> fetchJadwal() async {
    setLoading(true);
    setError(null);

    try {
      final response = await _eventService.getJadwal();
      final data = response.data;
      List rawList = [];

      // Penanganan response yang sangat fleksibel
      if (data is Map) {
        if (data['data'] is List) {
          rawList = data['data'];
        } else if (data['data'] is Map && data['data']['events'] is List) {
          rawList = data['data']['events'];
        } else if (data['events'] is List) {
          rawList = data['events'];
        }
      } else if (data is List) {
        rawList = data;
      }

      _events = rawList
          .whereType<Map>()
          .map((e) => EventModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (data is Map && data['data'] != null) {
        await CacheService.save('event_data', data['data']);
      } else if (rawList.isNotEmpty) {
        await CacheService.save('event_data', rawList);
      }
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memuat jadwal event');
      if (_events.isEmpty) _loadFromCache();
    } finally {
      setLoading(false);
    }
  }
}

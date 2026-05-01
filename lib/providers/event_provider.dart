import 'package:dio/dio.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../core/services/cache_service.dart';
import '../core/providers/base_provider.dart';

class EventProvider extends BaseProvider {
  final EventService _eventService;

  List<EventModel> _events = [];

  EventProvider(this._eventService) {
    _loadFromCache();
  }

  void _loadFromCache() {
    final cached = CacheService.get('event_data');
    if (cached != null) {
      final List data = cached ?? [];
      _events = data.map((e) => EventModel.fromJson(e)).toList();
    }
  }

  List<EventModel> get events => _events;

  Future<void> fetchJadwal() async {
    setLoading(true);
    setError(null);

    try {
      final response = await _eventService.getJadwal();
      final List data = response.data['data'] ?? [];
      _events = data.map((e) => EventModel.fromJson(e)).toList();

      await CacheService.save('event_data', response.data['data']);
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal memuat jadwal event');
      if (_events.isEmpty) _loadFromCache();
    } finally {
      setLoading(false);
    }
  }
}

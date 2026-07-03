import '../models/recommendation_model.dart';
import '../services/recommendation_service.dart';
import '../core/providers/base_provider.dart';

class RecommendationProvider extends BaseProvider {
  final RecommendationService _recommendationService;

  List<RecommendationModel> _recommendations = [];
  
  RecommendationProvider(this._recommendationService);

  List<RecommendationModel> get recommendations => _recommendations;

  Future<bool> fetchRecommendations({
    String? eventType,
    int? participants,
    required String date,
    List<String>? facilities,
    String? preference,
  }) async {
    setLoading(true);
    setError(null);
    _recommendations = [];
    notifyListeners();

    try {
      _recommendations = await _recommendationService.getRecommendations(
        eventType: eventType,
        participants: participants,
        date: date,
        facilities: facilities,
        preference: preference,
      );
      return true;
    } catch (e) {
      handleDioError(e, defaultMessage: 'Gagal mendapatkan rekomendasi');
      return false;
    } finally {
      setLoading(false);
    }
  }

  void clearRecommendations() {
    _recommendations = [];
    setError(null);
    notifyListeners();
  }
}

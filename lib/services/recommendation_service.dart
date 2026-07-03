import '../core/network/dio_client.dart';
import '../models/recommendation_model.dart';

class RecommendationService {
  final DioClient _dioClient;

  RecommendationService(this._dioClient);

  Future<List<RecommendationModel>> getRecommendations({
    String? eventType,
    int? participants,
    required String date,
    List<String>? facilities,
    String? preference,
  }) async {
    final response = await _dioClient.post('/recommendation', data: {
      'event_type': eventType,
      'participants': participants,
      'date': date,
      'facilities': facilities,
      'preference': preference,
    });

    if (response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data
          .map((e) => RecommendationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception(response.data['message'] ?? 'Gagal mengambil rekomendasi');
    }
  }
}

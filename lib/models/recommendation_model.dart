class RecommendationModel {
  final int id;
  final String name;
  final String slug;
  final double score;
  final String status;
  final bool available;
  final double? price;
  final int? capacity;
  final String? venueType;
  final bool isIndoor;
  final bool isOutdoor;
  final List<String> matchedFacilities;
  final List<String> reasons;
  final String? image;

  RecommendationModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.score,
    required this.status,
    required this.available,
    this.price,
    this.capacity,
    this.venueType,
    required this.isIndoor,
    required this.isOutdoor,
    required this.matchedFacilities,
    required this.reasons,
    this.image,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    // Helper untuk handle numeric (bisa int atau double dari API)
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return RecommendationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      score: toDouble(json['score']),
      status: json['status'] ?? 'Kurang Direkomendasikan',
      available: json['available'] ?? false,
      price: json['price'] != null ? toDouble(json['price']) : null,
      capacity: json['capacity'] != null ? toInt(json['capacity']) : null,
      venueType: json['venue_type'],
      isIndoor: json['is_indoor'] == true || json['is_indoor'] == 1,
      isOutdoor: json['is_outdoor'] == true || json['is_outdoor'] == 1,
      matchedFacilities: (json['matched_facilities'] as List?)?.map((e) => e.toString()).toList() ?? [],
      reasons: (json['reasons'] as List?)?.map((e) => e.toString()).toList() ?? [],
      image: json['image'],
    );
  }
}

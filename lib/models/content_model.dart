class ContentModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? priceWeekday;
  final String? priceWeekend;
  final String? openTime;
  final String? closeTime;
  final String? location;
  final String? locationEmbed;
  final String? image;
  final String? imageUrl; // Laravel API returns full URL here
  final String? instagram;
  final String? tiktok;
  final String? whatsapp;

  ContentModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.priceWeekday,
    this.priceWeekend,
    this.openTime,
    this.closeTime,
    this.location,
    this.locationEmbed,
    this.image,
    this.imageUrl,
    this.instagram,
    this.tiktok,
    this.whatsapp,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      priceWeekday: json['price_weekday']?.toString(),
      priceWeekend: json['price_weekend']?.toString(),
      openTime: json['open_time'],
      closeTime: json['close_time'],
      location: json['location'],
      locationEmbed: json['location_embed'],
      image: json['image'],
      imageUrl: json['image_url'],
      instagram: json['instagram'],
      tiktok: json['tiktok'],
      whatsapp: json['whatsapp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'description': description,
    'price_weekday': priceWeekday,
    'price_weekend': priceWeekend,
    'open_time': openTime,
    'close_time': closeTime,
    'location': location,
    'location_embed': locationEmbed,
    'image': image,
    'image_url': imageUrl,
    'instagram': instagram,
    'tiktok': tiktok,
    'whatsapp': whatsapp,
  };
}

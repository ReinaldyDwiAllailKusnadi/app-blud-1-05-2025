class UserModel {
  final int id;
  final String username;
  final String name;
  final String email;
  final String? phone;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
    );
  }
}

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
  final String? imageUrl;
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
      id: json['id'],
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
      whatsapp: json['whatsapp'],
    );
  }
}

class NewsModel {
  final int id;
  final String title;
  final String? content;
  final String? uploadTime;
  final String? source;
  final String? image;
  final String? imageUrl;

  NewsModel({
    required this.id,
    required this.title,
    this.content,
    this.uploadTime,
    this.source,
    this.image,
    this.imageUrl,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'],
      uploadTime: json['upload_time'],
      source: json['source'],
      image: json['image'],
      imageUrl: json['image_url'],
    );
  }
}

class EventModel {
  final int? id;
  final String nameEvent;
  final String startDate;
  final String endDate;
  final String? location;
  final String? vendor;
  final String? pdfUrl;
  final String type; // 'event' or 'submission'

  EventModel({
    this.id,
    required this.nameEvent,
    required this.startDate,
    required this.endDate,
    this.location,
    this.vendor,
    this.pdfUrl,
    required this.type,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      nameEvent: json['name_event'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      location: json['location'],
      vendor: json['vendor'],
      pdfUrl: json['pdf_url'],
      type: json['type'] ?? 'event',
    );
  }
}

class SubmissionModel {
  final int id;
  final int userId;
  final String namePIC;
  final String noHp;
  final String address;
  final String vendor;
  final String location;
  final String? applyDate;
  final String startDate;
  final String endDate;
  final String nameEvent;
  final String? file;
  final String? ktp;
  final String? applLetter;
  final String? actvLetter;
  final String? fileUrl;
  final String? ktpUrl;
  final String? applLetterUrl;
  final String? actvLetterUrl;
  final String status;
  final String? notes;

  SubmissionModel({
    required this.id,
    required this.userId,
    required this.namePIC,
    required this.noHp,
    required this.address,
    required this.vendor,
    required this.location,
    this.applyDate,
    required this.startDate,
    required this.endDate,
    required this.nameEvent,
    this.file,
    this.ktp,
    this.applLetter,
    this.actvLetter,
    this.fileUrl,
    this.ktpUrl,
    this.applLetterUrl,
    this.actvLetterUrl,
    required this.status,
    this.notes,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'],
      userId: json['user_id'],
      namePIC: json['namePIC'] ?? '',
      noHp: json['no_hp'] ?? '',
      address: json['address'] ?? '',
      vendor: json['vendor'] ?? '',
      location: json['location'] ?? '',
      applyDate: json['apply_date'],
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      nameEvent: json['name_event'] ?? '',
      file: json['file'],
      ktp: json['ktp'],
      applLetter: json['appl_letter'],
      actvLetter: json['actv_letter'],
      fileUrl: json['file_url'],
      ktpUrl: json['ktp_url'],
      applLetterUrl: json['appl_letter_url'],
      actvLetterUrl: json['actv_letter_url'],
      status: json['status'] ?? 'pending',
      notes: json['notes'],
    );
  }
}

class ContentFeatureModel {
  final int id;
  final int location;
  final String type; // 'price' or 'facility'
  final String? bagian;
  final String? luas;
  final int? price;
  final String? facilityName;

  ContentFeatureModel({
    required this.id,
    required this.location,
    required this.type,
    this.bagian,
    this.luas,
    this.price,
    this.facilityName,
  });

  factory ContentFeatureModel.fromJson(Map<String, dynamic> json) {
    return ContentFeatureModel(
      id: json['id'],
      location: json['location'],
      type: json['type'] ?? '',
      bagian: json['bagian'],
      luas: json['luas'],
      price: json['price'],
      facilityName: json['facility_name'],
    );
  }
}

class JadwalBulanModel {
  final String bulan;
  final int jumlahEvent;
  final List<EventModel> events;

  JadwalBulanModel({
    required this.bulan,
    required this.jumlahEvent,
    required this.events,
  });

  factory JadwalBulanModel.fromJson(Map<String, dynamic> json) {
    return JadwalBulanModel(
      bulan: json['bulan'] ?? '',
      jumlahEvent: json['jumlah_event'] ?? 0,
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => EventModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

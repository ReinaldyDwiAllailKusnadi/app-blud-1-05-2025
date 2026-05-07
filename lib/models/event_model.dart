class EventModel {
  final int id;
  final String nameEvent;
  final String startDate;
  final String endDate;
  final String? location;
  final String? vendor;
  final String? file;
  final String? fileUrl;
  final String? status;

  EventModel({
    required this.id,
    required this.nameEvent,
    required this.startDate,
    required this.endDate,
    this.location,
    this.vendor,
    this.file,
    this.fileUrl,
    this.status,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: parseInt(json['id']),
      nameEvent: json['name_event']?.toString() ?? '-',
      startDate: json['start_date']?.toString() ?? '-',
      endDate: json['end_date']?.toString() ?? '-',
      location: json['location']?.toString() ?? '-',
      vendor: json['vendor']?.toString() ?? '-',
      file: json['file']?.toString(),
      fileUrl: json['file_url']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name_event': nameEvent,
    'start_date': startDate,
    'end_date': endDate,
    'location': location,
    'vendor': vendor,
    'file': file,
    'file_url': fileUrl,
    'status': status,
  };

  // Helper static methods for safe parsing
  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}

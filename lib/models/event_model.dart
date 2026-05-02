class EventModel {
  final int id;
  final String nameEvent;
  final String startDate;
  final String endDate;
  final String? location;
  final String? vendor;
  final String? file;
  final String? fileUrl;

  EventModel({
    required this.id,
    required this.nameEvent,
    required this.startDate,
    required this.endDate,
    this.location,
    this.vendor,
    this.file,
    this.fileUrl,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? 0,
      nameEvent: json['name_event'] ?? json['title'] ?? json['name'] ?? '-',
      startDate: json['start_date'] ?? '-',
      endDate: json['end_date'] ?? '-',
      location: json['location'] ?? '-',
      vendor: json['vendor'],
      file: json['file'],
      fileUrl: json['file_url'],
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
  };
}

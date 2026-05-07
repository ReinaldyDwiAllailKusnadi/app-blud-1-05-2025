class SubmissionModel {
  final int id;
  final int? userId;
  final String namePIC;
  final String noHp;
  final String address;
  final String vendor;
  final String location;
  final String? applyDate;
  final String startDate;
  final String endDate;
  final String nameEvent;
  final String status;
  final String? notes;
  final String? file;
  final String? ktp;
  final String? applLetter;
  final String? actvLetter;
  final String? fileUrl;
  final String? ktpUrl;
  final String? applLetterUrl;
  final String? actvLetterUrl;

  SubmissionModel({
    required this.id,
    this.userId,
    required this.namePIC,
    required this.noHp,
    required this.address,
    required this.vendor,
    required this.location,
    this.applyDate,
    required this.startDate,
    required this.endDate,
    required this.nameEvent,
    required this.status,
    this.notes,
    this.file,
    this.ktp,
    this.applLetter,
    this.actvLetter,
    this.fileUrl,
    this.ktpUrl,
    this.applLetterUrl,
    this.actvLetterUrl,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: parseInt(json['id']),
      userId: parseNullableInt(json['user_id']),
      namePIC: parseString(json['namePIC']),
      noHp: parseString(json['no_hp']),
      address: parseString(json['address']),
      vendor: parseString(json['vendor']),
      location: parseString(json['location']),
      applyDate: json['apply_date']?.toString(),
      startDate: parseString(json['start_date'], defaultValue: ''),
      endDate: parseString(json['end_date'], defaultValue: ''),
      nameEvent: parseString(json['name_event']),
      status: parseString(json['status'], defaultValue: 'pending'),
      notes: json['notes']?.toString(),
      file: json['file']?.toString(),
      ktp: json['ktp']?.toString(),
      applLetter: json['appl_letter']?.toString(),
      actvLetter: json['actv_letter']?.toString(),
      fileUrl: json['file_url']?.toString(),
      ktpUrl: json['ktp_url']?.toString(),
      applLetterUrl: json['appl_letter_url']?.toString(),
      actvLetterUrl: json['actv_letter_url']?.toString(),
    );
  }

  // Helper static methods for safe parsing
  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static int? parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String parseString(dynamic value, {String defaultValue = '-'}) {
    if (value == null) return defaultValue;
    return value.toString();
  }
}

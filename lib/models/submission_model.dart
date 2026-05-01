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
      id: json['id'] ?? 0,
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
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      file: json['file'],
      ktp: json['ktp'],
      applLetter: json['appl_letter'],
      actvLetter: json['actv_letter'],
      fileUrl: json['file_url'],
      ktpUrl: json['ktp_url'],
      applLetterUrl: json['appl_letter_url'],
      actvLetterUrl: json['actv_letter_url'],
    );
  }
}

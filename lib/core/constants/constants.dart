class ApiConstants {
  // Ganti dengan URL server Laravel kamu
  // Untuk testing lokal: 'http://10.0.2.2:8000/api' (Android emulator)
  // Untuk device fisik: 'http://IP_KOMPUTER:8000/api'
  static const String baseUrl = 'https://bludpariwisata.com/api';
  
  // Ganti dengan URL storage Laravel
  static const String storageUrl = 'https://bludpariwisata.com/storage';
}

class AppStrings {
  static const String appName = 'BLUD Pariwisata';
  static const String appTagline = 'Wisata Banyumas';

  // Auth
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String logout = 'Keluar';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Konfirmasi Password';
  static const String name = 'Nama Lengkap';
  static const String phone = 'Nomor HP';
  static const String loginWithGoogle = 'Masuk dengan Google';

  // Navigation
  static const String home = 'Beranda';
  static const String wisata = 'Wisata';
  static const String jadwal = 'Jadwal';
  static const String booking = 'Booking';
  static const String profile = 'Profil';

  // Submission
  static const String formPengajuan = 'Form Pengajuan Sewa';
  static const String riwayat = 'Riwayat Pengajuan';
  static const String pending = 'Pending';
  static const String approved = 'Approved';
  static const String rejected = 'Rejected';
}

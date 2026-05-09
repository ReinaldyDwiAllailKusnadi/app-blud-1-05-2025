# Walkthrough: Integrasi SPK Recommendation di Flutter

Fitur SPK Knowledge-Based Recommendation kini telah terintegrasi sepenuhnya ke dalam aplikasi mobile Flutter. Pengguna dapat mencari rekomendasi lokasi berdasarkan kebutuhan kegiatan dan langsung melanjutkan ke pengajuan sewa.

## Perubahan Utama

### 1. Data Layer & Service
- **`RecommendationModel`**: Model data untuk memetakan response dari API Laravel `POST /api/recommendation`.
- **`RecommendationService`**: Service yang menangani request HTTP ke backend menggunakan `DioClient`.
- **`RecommendationProvider`**: State management menggunakan Provider untuk mengelola loading, error, dan data hasil rekomendasi.

### 2. Antarmuka Pengguna (UI)
- **`RecommendationScreen`**: Halaman baru dengan formulir input (Jenis Kegiatan, Peserta, Tanggal, Budget, Fasilitas, Preferensi) dan daftar hasil yang diurutkan berdasarkan skor kemiripan.
- **`MainScreen` (Tabs)**: Integrasi tab baru "Rekomendasi" (dengan ikon auto-awesome) sebagai navigasi utama.
- **`HomeScreen` (Shortcut Card)**: Penambahan kartu promo/shortcut di halaman Beranda untuk mengajak pengguna mencoba fitur rekomendasi jika mereka bingung memilih lokasi.

### 3. Alur Kerja Terintegrasi
- Hasil rekomendasi menampilkan skor, alasan pemilihan, dan status ketersediaan.
- Tombol **"Ajukan Sewa"** pada hasil rekomendasi akan mengarahkan pengguna ke `SubmissionFormScreen` dengan data **Lokasi** dan **Tanggal** yang sudah terisi otomatis (pre-filled).

## Cara Pengujian
1. Buka aplikasi Flutter.
2. Klik tab **Rekomendasi** atau kartu **"Mulai Rekomendasi"** di halaman Home.
3. Isi data kegiatan (wajib isi Tanggal).
4. Klik **"Cari Rekomendasi"**.
5. Lihat daftar lokasi yang muncul.
6. Klik **"Ajukan Sewa"** pada salah satu hasil untuk melihat pre-fill data di form pengajuan.

> [!NOTE]
> Pastikan backend Laravel sudah berjalan dan API `/api/recommendation` dapat diakses.

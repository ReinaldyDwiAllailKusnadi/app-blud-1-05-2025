# 4.1.3 Perancangan Sistem
## 4.1.3.1 Use Case Diagram

Use case diagram merupakan diagram yang menggambarkan interaksi antara sistem dan aktor eksternal. Diagram ini mendefinisikan fungsionalitas yang disediakan oleh sistem dan bagaimana aktor menggunakannya untuk mencapai tujuan tertentu. Pada perancangan sistem ini, use case diagram difokuskan pada fitur-fitur yang terdapat pada aplikasi pengajuan sewa berbasis mobile, serta fungsionalitas pengelolaan data pendukung dan verifikasi pengajuan oleh petugas melalui *dashboard* web yang terhubung.

Aktor yang diidentifikasi pada sistem ini terdiri dari dua pihak utama, yaitu Masyarakat / Pemohon Sewa yang bertindak sebagai pengguna aplikasi mobile, dan Petugas BLUD yang mengelola operasional dan memverifikasi pengajuan.

**Tabel 4.x Aktor Sistem**
| Aktor | Deskripsi | Hak Akses Utama |
|---|---|---|
| Masyarakat / Pemohon Sewa | Masyarakat umum atau instansi yang menggunakan aplikasi mobile untuk mencari informasi lokasi wisata dan melakukan pengajuan sewa. | Mengakses informasi wisata, melakukan pendaftaran, menggunakan fitur rekomendasi lokasi, mengirimkan form pengajuan sewa lengkap dengan dokumen lampiran, dan melacak status pengajuannya. |
| Petugas BLUD | Staf pengelola (admin) dari BLUD Teratai Mas yang bertugas memverifikasi pengajuan dan memperbarui data informasi lokasi wisata. | Mengelola data lokasi wisata, fasilitas, jadwal kegiatan, melihat detail pengajuan sewa, mengunduh dokumen lampiran pengajuan, serta memberikan persetujuan atau penolakan terhadap pengajuan sewa. |

Tabel berikut menyajikan daftar *use case* yang terdapat dalam sistem aplikasi pengajuan sewa berbasis mobile beserta deskripsi fungsinya.

**Tabel 4.y Daftar Use Case**
| Kode | Aktor | Use Case | Deskripsi |
|---|---|---|---|
| UC-01 | Masyarakat / Pemohon Sewa | Registrasi Akun | Proses pembuatan akun baru agar masyarakat dapat login ke dalam aplikasi. |
| UC-02 | Masyarakat / Pemohon Sewa, Petugas BLUD | Login | Proses autentikasi untuk masuk ke dalam sistem sesuai hak akses. |
| UC-03 | Masyarakat / Pemohon Sewa, Petugas BLUD | Logout | Proses keluar dari sesi akun yang sedang aktif. |
| UC-04 | Masyarakat / Pemohon Sewa | Melihat Beranda | Proses menampilkan halaman utama aplikasi setelah login. |
| UC-05 | Masyarakat / Pemohon Sewa | Melihat Daftar Lokasi Wisata | Proses menampilkan seluruh daftar lokasi wisata yang tersedia di BLUD Teratai Mas. |
| UC-06 | Masyarakat / Pemohon Sewa | Melihat Detail Lokasi Wisata | Proses menampilkan informasi rinci dari lokasi wisata yang dipilih. |
| UC-07 | Masyarakat / Pemohon Sewa | Melihat Fasilitas dan Harga | Proses menampilkan daftar fasilitas dan harga yang tersedia pada lokasi wisata tertentu (Include dari UC-06). |
| UC-08 | Masyarakat / Pemohon Sewa | Melihat Jadwal Lokasi Wisata | Proses menampilkan kalender/jadwal ketersediaan atau acara pada lokasi wisata. |
| UC-09 | Masyarakat / Pemohon Sewa | Menggunakan Rekomendasi Lokasi | Proses sistem memberikan rekomendasi lokasi yang sesuai dengan kebutuhan pemohon. |
| UC-10 | Masyarakat / Pemohon Sewa | Mengisi Kriteria Rekomendasi | Proses pengguna memasukkan kriteria (tujuan, fasilitas) untuk rekomendasi (Include dari UC-09). |
| UC-11 | Masyarakat / Pemohon Sewa | Melihat Hasil Rekomendasi | Proses menampilkan hasil rekomendasi berdasarkan kriteria yang dimasukkan (Include dari UC-09). |
| UC-12 | Masyarakat / Pemohon Sewa | Melihat Skor/Status Rekomendasi | Proses melihat detail kecocokan skor rekomendasi lokasi (Include dari UC-11). |
| UC-13 | Masyarakat / Pemohon Sewa | Mengajukan Sewa Lokasi | Proses utama pembuatan permohonan pengajuan penyewaan lokasi wisata. |
| UC-14 | Masyarakat / Pemohon Sewa | Mengisi Form Pengajuan Sewa | Proses melengkapi data kegiatan, waktu sewa, dan informasi PIC (Include dari UC-13). |
| UC-15 | Masyarakat / Pemohon Sewa | Mengunggah Dokumen Lampiran | Proses melampirkan berkas yang dibutuhkan untuk verifikasi (Include dari UC-13). |
| UC-16 | Masyarakat / Pemohon Sewa | Mengunggah Proposal PDF | Proses melampirkan file proposal kegiatan (Include dari UC-15). |
| UC-17 | Masyarakat / Pemohon Sewa | Mengunggah KTP PDF | Proses melampirkan file scan KTP penanggung jawab (Include dari UC-15). |
| UC-18 | Masyarakat / Pemohon Sewa | Mengunggah Surat Pengajuan PDF | Proses melampirkan surat permohonan penyewaan (Include dari UC-15). |
| UC-19 | Masyarakat / Pemohon Sewa | Mengunggah Surat Kegiatan PDF | Proses melampirkan surat izin/rekomendasi kegiatan (Include dari UC-15). |
| UC-20 | Masyarakat / Pemohon Sewa | Mengirim Pengajuan Sewa | Proses pengiriman seluruh data pengajuan kepada Petugas BLUD setelah divalidasi sistem (Include dari UC-13). |
| UC-21 | Masyarakat / Pemohon Sewa | Melihat Riwayat Pengajuan | Proses melihat daftar pengajuan sewa yang pernah atau sedang dilakukan. |
| UC-22 | Masyarakat / Pemohon Sewa | Melihat Status Pengajuan | Proses mengecek apakah pengajuan dalam status *Pending*, *Approved*, atau *Rejected* (Include dari UC-21). |
| UC-23 | Masyarakat / Pemohon Sewa | Mengunduh Lampiran Pengajuan | Proses pengguna mengunduh kembali dokumen yang telah diunggah atau surat balasan (Extend dari UC-21). |
| UC-24 | Masyarakat / Pemohon Sewa | Melihat Profil | Proses menampilkan informasi profil pengguna. |
| UC-25 | Masyarakat / Pemohon Sewa | Mengubah Profil | Proses memperbarui informasi profil pengguna seperti nama dan nomor HP (Extend dari UC-24). |
| UC-26 | Petugas BLUD | Mengelola Data Lokasi Wisata | Proses CRUD (Create, Read, Update, Delete) informasi lokasi wisata. |
| UC-27 | Petugas BLUD | Mengelola Fasilitas dan Harga | Proses mengelola daftar ketersediaan fasilitas dan harganya pada setiap lokasi. |
| UC-28 | Petugas BLUD | Mengelola Jadwal Lokasi Wisata | Proses menetapkan ketersediaan tanggal atau agenda kegiatan pada lokasi. |
| UC-29 | Petugas BLUD | Melihat Daftar Pengajuan Sewa | Proses melihat rekapitulasi semua pengajuan sewa yang masuk ke sistem. |
| UC-30 | Petugas BLUD | Melihat Detail Pengajuan Sewa | Proses memeriksa rincian form pengajuan dan dokumen yang diunggah pemohon (Include dari UC-29). |
| UC-31 | Petugas BLUD | Mengunduh Lampiran Pengajuan | Proses petugas mengunduh dokumen KTP, Proposal, dll untuk divalidasi (Extend dari UC-30). |
| UC-32 | Petugas BLUD | Menyetujui Pengajuan | Proses mengubah status pengajuan menjadi *Approved* jika data valid (Include dari UC-30). |
| UC-33 | Petugas BLUD | Menolak Pengajuan | Proses mengubah status pengajuan menjadi *Rejected* dengan memberikan alasan jika data tidak valid (Include dari UC-30). |

*Catatan Verifikasi Fitur:*
Fitur-fitur yang dideskripsikan di atas telah divalidasi berdasarkan *source code* pada aplikasi Flutter (`submission_form_screen.dart`, `submission_history_screen.dart`, `recommendation_screen.dart`, dll) dan modul API backend Laravel (`SubmissionController.php`, `WisataApiController.php`, dll). Fitur administrasi Petugas BLUD sengaja dibatasi hanya pada hal yang berkaitan langsung dengan sinkronisasi data aplikasi mobile.

**Diagram Use Case**
```plantuml
@startuml
left to right direction
skinparam packageStyle rectangle

actor "Masyarakat /\nPemohon Sewa" as User
actor "Petugas BLUD" as Admin

rectangle "Aplikasi Pengajuan Sewa Lokasi Wisata BLUD Teratai Mas" {

  package "Autentikasi" {
    usecase "Registrasi Akun" as UC_Reg
    usecase "Login" as UC_Login
    usecase "Logout" as UC_Logout
  }
  
  package "Informasi Lokasi Wisata" {
    usecase "Melihat Beranda" as UC_Home
    usecase "Melihat Daftar Lokasi Wisata" as UC_Wisata
    usecase "Melihat Detail Lokasi Wisata" as UC_DetailWisata
    usecase "Melihat Fasilitas dan Harga" as UC_Fasilitas
    usecase "Melihat Jadwal Lokasi Wisata" as UC_Jadwal
  }
  
  package "Rekomendasi Lokasi" {
    usecase "Menggunakan Rekomendasi Lokasi" as UC_Rec
    usecase "Mengisi Kriteria Rekomendasi" as UC_RecKriteria
    usecase "Melihat Hasil Rekomendasi" as UC_RecHasil
    usecase "Melihat Skor/Status Rekomendasi" as UC_RecSkor
  }

  package "Pengajuan Sewa" {
    usecase "Mengajukan Sewa Lokasi" as UC_Sewa
    usecase "Mengisi Form Pengajuan Sewa" as UC_FormSewa
    usecase "Mengunggah Dokumen Lampiran" as UC_UploadDoc
    usecase "Mengunggah Proposal PDF" as UC_UpProp
    usecase "Mengunggah KTP PDF" as UC_UpKTP
    usecase "Mengunggah Surat Pengajuan PDF" as UC_UpPengajuan
    usecase "Mengunggah Surat Kegiatan PDF" as UC_UpKegiatan
    usecase "Mengirim Pengajuan Sewa" as UC_KirimSewa
  }

  package "Riwayat dan Profil" {
    usecase "Melihat Riwayat Pengajuan" as UC_Riwayat
    usecase "Melihat Status Pengajuan" as UC_Status
    usecase "Mengunduh Lampiran Pengajuan" as UC_UnduhUser
    usecase "Melihat Profil" as UC_Profil
    usecase "Mengubah Profil" as UC_UbahProfil
  }
  
  package "Pengelolaan oleh Petugas BLUD" {
    usecase "Mengelola Data Lokasi Wisata" as UC_KelolaLokasi
    usecase "Mengelola Fasilitas dan Harga" as UC_KelolaFasilitas
    usecase "Mengelola Jadwal Lokasi Wisata" as UC_KelolaJadwal
    usecase "Melihat Daftar Pengajuan Sewa" as UC_DaftarSewaAdmin
    usecase "Melihat Detail Pengajuan Sewa" as UC_DetailSewaAdmin
    usecase "Mengunduh Lampiran Pengajuan" as UC_UnduhAdmin
    usecase "Menyetujui Pengajuan" as UC_SetujuSewa
    usecase "Menolak Pengajuan" as UC_TolakSewa
  }
}

User --> UC_Reg
User --> UC_Login
User --> UC_Logout
User --> UC_Home
User --> UC_Wisata
User --> UC_DetailWisata
User --> UC_Jadwal
User --> UC_Rec
User --> UC_Sewa
User --> UC_Riwayat
User --> UC_Profil

Admin --> UC_Login
Admin --> UC_Logout
Admin --> UC_KelolaLokasi
Admin --> UC_KelolaFasilitas
Admin --> UC_KelolaJadwal
Admin --> UC_DaftarSewaAdmin

UC_DetailWisata ..> UC_Fasilitas : <<include>>

UC_Rec ..> UC_RecKriteria : <<include>>
UC_Rec ..> UC_RecHasil : <<include>>
UC_RecHasil ..> UC_RecSkor : <<include>>

UC_Sewa ..> UC_FormSewa : <<include>>
UC_Sewa ..> UC_UploadDoc : <<include>>
UC_Sewa ..> UC_KirimSewa : <<include>>

UC_UploadDoc ..> UC_UpProp : <<include>>
UC_UploadDoc ..> UC_UpKTP : <<include>>
UC_UploadDoc ..> UC_UpPengajuan : <<include>>
UC_UploadDoc ..> UC_UpKegiatan : <<include>>

UC_Riwayat ..> UC_Status : <<include>>
UC_UnduhUser ..> UC_Riwayat : <<extend>>

UC_UbahProfil ..> UC_Profil : <<extend>>

UC_DaftarSewaAdmin ..> UC_DetailSewaAdmin : <<include>>
UC_UnduhAdmin ..> UC_DetailSewaAdmin : <<extend>>
UC_SetujuSewa ..> UC_DetailSewaAdmin : <<include>>
UC_TolakSewa ..> UC_DetailSewaAdmin : <<include>>

@enduml
```

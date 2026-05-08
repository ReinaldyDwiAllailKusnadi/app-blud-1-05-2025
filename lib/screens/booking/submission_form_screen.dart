import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio;
import '../../providers/auth_provider.dart';
import '../../providers/submission_provider.dart';
import '../auth/login_screen.dart';
import '../../core/widgets/pressable.dart';

class SubmissionFormScreen extends StatefulWidget {
  const SubmissionFormScreen({super.key});

  @override
  State<SubmissionFormScreen> createState() => _SubmissionFormScreenState();
}

class _SubmissionFormScreenState extends State<SubmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _namePicCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _vendorCtrl = TextEditingController();
  final _eventNameCtrl = TextEditingController();
  
  // Form State
  String? _selectedLocation;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Files
  PlatformFile? _file;
  PlatformFile? _ktp;
  PlatformFile? _applLetter;
  PlatformFile? _actvLetter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubmissionProvider>().fetchLocationOptions();
    });
  }

  @override
  void dispose() {
    _namePicCtrl.dispose();
    _noHpCtrl.dispose();
    _addressCtrl.dispose();
    _vendorCtrl.dispose();
    _eventNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    List<String> extensions = ['pdf'];
    if (type == 'ktp') extensions = ['pdf', 'jpg', 'jpeg', 'png'];

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
    );

    if (result != null) {
      setState(() {
        switch (type) {
          case 'file': _file = result.files.first; break;
          case 'ktp': _ktp = result.files.first; break;
          case 'appl_letter': _applLetter = result.files.first; break;
          case 'actv_letter': _actvLetter = result.files.first; break;
        }
      });
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? (_startDate ?? DateTime.now())),
      firstDate: isStart ? DateTime.now() : (_startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1461D2),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi data pengajuan terlebih dahulu.')),
      );
      return;
    }

    if (_ktp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File KTP wajib diunggah.')),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal mulai dan selesai wajib diisi.')),
      );
      return;
    }

    final provider = context.read<SubmissionProvider>();
    
    // Construct FormData map with non-null values
    final formDataMap = <String, dynamic>{
      'namePIC': _namePicCtrl.text.trim(),
      'no_hp': _noHpCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'vendor': _vendorCtrl.text.trim(),
      'location': _selectedLocation,
      'name_event': _eventNameCtrl.text.trim(),
      'start_date': DateFormat('yyyy-MM-dd').format(_startDate!),
      'end_date': DateFormat('yyyy-MM-dd').format(_endDate!),
    };

    final formData = dio.FormData.fromMap(formDataMap);

    // Add Files (only if not null)
    final ktpFile = await SubmissionProvider.multipartFromPickedFile(_ktp);
    if (ktpFile != null) {
      formData.files.add(MapEntry('ktp', ktpFile));
    }

    if (_file != null) {
      final proposalFile = await SubmissionProvider.multipartFromPickedFile(_file);
      if (proposalFile != null) formData.files.add(MapEntry('file', proposalFile));
    }

    if (_applLetter != null) {
      final applFile = await SubmissionProvider.multipartFromPickedFile(_applLetter);
      if (applFile != null) formData.files.add(MapEntry('appl_letter', applFile));
    }

    if (_actvLetter != null) {
      final actvFile = await SubmissionProvider.multipartFromPickedFile(_actvLetter);
      if (actvFile != null) formData.files.add(MapEntry('actv_letter', actvFile));
    }

    final success = await provider.submitBooking(formData);

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Berhasil'),
          content: const Text('Pengajuan sewa berhasil dikirim. Silakan menunggu verifikasi admin.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal mengirim pengajuan.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final topPadding = MediaQuery.of(context).padding.top;

    if (!auth.isLoggedIn) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_person_rounded, size: 80, color: Color(0xFF64748B)),
                const SizedBox(height: 24),
                Text(
                  'Akses Terbatas',
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Silakan login terlebih dahulu untuk mengajukan sewa tempat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1461D2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('LOGIN SEKARANG'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Consumer<SubmissionProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              // Blue Gradient Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 200,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF20A8F4), Color(0xFF142B9A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Content
              Column(
                children: [
                  // App Bar
                  Padding(
                    padding: EdgeInsets.only(top: topPadding + 10, left: 10, right: 20),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        ),
                        const Expanded(
                          child: Text(
                            'Form Pengajuan Sewa',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 40), // Spacing for balance
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data Pengajuan Sewa',
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 20),
                              _buildField(
                                label: 'Nama PIC',
                                controller: _namePicCtrl,
                                icon: Icons.person_rounded,
                                hint: 'Nama lengkap penanggung jawab',
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                label: 'Nomor HP (WhatsApp)',
                                controller: _noHpCtrl,
                                icon: Icons.phone_android_rounded,
                                hint: 'Contoh: 08123456789',
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                label: 'Alamat',
                                controller: _addressCtrl,
                                icon: Icons.home_work_rounded,
                                hint: 'Alamat lengkap instansi/pribadi',
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                label: 'Vendor / Instansi',
                                controller: _vendorCtrl,
                                icon: Icons.business_center_rounded,
                                hint: 'Nama organisasi atau vendor sewa',
                              ),
                              
                              const SizedBox(height: 32),
                              Text(
                                'Detail Kegiatan',
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 20),
                              _buildDropdown(
                                label: 'Lokasi Wisata / Tempat',
                                value: _selectedLocation,
                                items: provider.locationOptions.map((l) => l.name).toList(),
                                onChanged: (v) => setState(() => _selectedLocation = v),
                                icon: Icons.location_on_rounded,
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                label: 'Nama Kegiatan',
                                controller: _eventNameCtrl,
                                icon: Icons.event_note_rounded,
                                hint: 'Judul atau deskripsi singkat acara',
                              ),
                              const SizedBox(height: 16),
                              // Date selection with LayoutBuilder to prevent overflow
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isSmall = constraints.maxWidth < 360;
                                  
                                  if (isSmall) {
                                    return Column(
                                      children: [
                                        _buildDatePicker(
                                          label: 'Tanggal Mulai',
                                          date: _startDate,
                                          onTap: () => _pickDate(true),
                                        ),
                                        const SizedBox(height: 14),
                                        _buildDatePicker(
                                          label: 'Tanggal Selesai',
                                          date: _endDate,
                                          onTap: () => _pickDate(false),
                                        ),
                                      ],
                                    );
                                  }
                                  
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildDatePicker(
                                          label: 'Tanggal Mulai',
                                          date: _startDate,
                                          onTap: () => _pickDate(true),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildDatePicker(
                                          label: 'Tanggal Selesai',
                                          date: _endDate,
                                          onTap: () => _pickDate(false),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 32),
                              Text(
                                'Unggah Dokumen',
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pastikan file terbaca dengan jelas (PDF/Gambar)',
                                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 20),
                              _buildFilePicker(
                                label: 'File KTP (Wajib)',
                                file: _ktp,
                                onPick: () => _pickFile('ktp'),
                                isRequired: true,
                              ),
                              _buildFilePicker(
                                label: 'File Proposal (PDF)',
                                file: _file,
                                onPick: () => _pickFile('file'),
                              ),
                              _buildFilePicker(
                                label: 'Surat Pengajuan (PDF)',
                                file: _applLetter,
                                onPick: () => _pickFile('appl_letter'),
                              ),
                              _buildFilePicker(
                                label: 'Surat Rundown / Kegiatan (PDF)',
                                file: _actvLetter,
                                onPick: () => _pickFile('actv_letter'),
                              ),

                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: provider.isLoading ? null : const LinearGradient(
                                      colors: [Color(0xFF20A8F4), Color(0xFF142B9A)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    color: provider.isLoading ? Colors.grey : null,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF142B9A).withValues(alpha: 0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Pressable(
                                    onTap: provider.isLoading ? null : _submit,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Center(
                                      child: provider.isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                            )
                                          : Text(
                                              'AJUKAN SEWA SEKARANG',
                                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF1461D2), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1461D2), width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
        ),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF1461D2), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1461D2), width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
          ),
          selectedItemBuilder: (context) {
            return items.map((String item) {
              return Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            }).toList();
          },
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? 'Pilih lokasi' : null,
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
        ),
        Pressable(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, color: Color(0xFF1461D2), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Pilih',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: date != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePicker({
    required String label,
    required PlatformFile? file,
    required VoidCallback onPick,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Pressable(
        onTap: onPick,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: file != null ? const Color(0xFFF0F9FF) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: file != null ? const Color(0xFF1461D2) : const Color(0xFFE2E8F0),
              width: file != null ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                file != null ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
                color: const Color(0xFF1461D2),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    if (file != null)
                      Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF1461D2), fontWeight: FontWeight.w500),
                      )
                    else
                      Text(
                        isRequired ? 'Wajib (Format PDF/JPG/PNG)' : 'Opsional (Format PDF)',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                      ),
                  ],
                ),
              ),
              if (file != null)
                const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF64748B)),
            ],
          ),
        ),
      ),
    );
  }
}

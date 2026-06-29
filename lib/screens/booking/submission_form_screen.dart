import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio;
import '../../providers/auth_provider.dart';
import '../../providers/submission_provider.dart';
import '../auth/login_screen.dart';
import '../../core/widgets/pressable.dart';
import '../../models/content_model.dart';

class SubmissionFormScreen extends StatefulWidget {
  final String? prefilledLocation;
  final int? prefilledLocationId;
  final String? prefilledLocationSlug;
  final DateTime? prefilledDate;

  const SubmissionFormScreen({
    super.key,
    this.prefilledLocation,
    this.prefilledLocationId,
    this.prefilledLocationSlug,
    this.prefilledDate,
  });

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
  
  final _scrollController = ScrollController();
  
  // Form State
  int? _selectedLocationId;
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
    _selectedLocationId = widget.prefilledLocationId;
    _startDate = widget.prefilledDate;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubmissionProvider>().fetchLocationOptions();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _namePicCtrl.dispose();
    _noHpCtrl.dispose();
    _addressCtrl.dispose();
    _vendorCtrl.dispose();
    _eventNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final file = result.files.first;
      
      // Additional validation for KTP
      if (type == 'ktp' && file.extension?.toLowerCase() != 'pdf') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File KTP harus berformat PDF.')),
          );
        }
        return;
      }

      setState(() {
        switch (type) {
          case 'file': _file = file; break;
          case 'ktp': _ktp = file; break;
          case 'appl_letter': _applLetter = file; break;
          case 'actv_letter': _actvLetter = file; break;
        }
      });
      // Clear error for this field
      if (!mounted) return;
      context.read<SubmissionProvider>().clearFieldError(type);
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
          context.read<SubmissionProvider>().clearFieldError('start_date');
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
          context.read<SubmissionProvider>().clearFieldError('end_date');
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

    // Phone Number Validation (10-12 digits)
    final phone = _noHpCtrl.text.trim();
    if (phone.length < 10 || phone.length > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor HP minimal 10 digit dan maksimal 12 digit.')),
      );
      return;
    }

    if (_file == null || _ktp == null || _applLetter == null || _actvLetter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua dokumen wajib diunggah dalam format PDF.')),
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
      'content_id': _selectedLocationId,
      'name_event': _eventNameCtrl.text.trim(),
      'start_date': _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : null,
      'end_date': _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null,
    };

    final formData = dio.FormData.fromMap(formDataMap);

    // Add Files (only if not null)
    if (_ktp != null) {
      final ktpFile = await SubmissionProvider.multipartFromPickedFile(_ktp);
      if (ktpFile != null) formData.files.add(MapEntry('ktp', ktpFile));
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
      // Scroll to first error
      if (provider.fieldErrors.isNotEmpty) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal mengirim pengajuan.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
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
                      controller: _scrollController,
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
                                errorText: provider.fieldErrors['namePIC']?.first,
                                onChanged: (v) => provider.clearFieldError('namePIC'),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Nama PIC wajib diisi';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                label: 'Nomor HP (WhatsApp)',
                                controller: _noHpCtrl,
                                icon: Icons.phone_android_rounded,
                                hint: 'Contoh: 08123456789',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(12),
                                ],
                                errorText: provider.fieldErrors['no_hp']?.first,
                                onChanged: (v) => provider.clearFieldError('no_hp'),
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                label: 'Alamat',
                                controller: _addressCtrl,
                                icon: Icons.home_work_rounded,
                                hint: 'Alamat lengkap instansi/pribadi',
                                errorText: provider.fieldErrors['address']?.first,
                                onChanged: (v) => provider.clearFieldError('address'),
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                label: 'Vendor / Instansi',
                                controller: _vendorCtrl,
                                icon: Icons.business_center_rounded,
                                hint: 'Nama organisasi atau vendor sewa',
                                errorText: provider.fieldErrors['vendor']?.first,
                                onChanged: (v) => provider.clearFieldError('vendor'),
                              ),
                              
                              const SizedBox(height: 32),
                              Text(
                                'Detail Kegiatan',
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 20),
                               _buildDropdown(
                                label: 'Lokasi Wisata / Tempat',
                                value: _selectedLocationId,
                                items: provider.locationOptions,
                                onChanged: (v) {
                                  setState(() => _selectedLocationId = v);
                                  provider.clearFieldError('content_id');
                                },
                                icon: Icons.location_on_rounded,
                                errorText: provider.fieldErrors['content_id']?.first,
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                label: 'Nama Kegiatan',
                                controller: _eventNameCtrl,
                                icon: Icons.event_note_rounded,
                                hint: 'Judul atau deskripsi singkat acara',
                                errorText: provider.fieldErrors['name_event']?.first,
                                onChanged: (v) => provider.clearFieldError('name_event'),
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
                                          errorText: provider.fieldErrors['start_date']?.first,
                                        ),
                                        const SizedBox(height: 14),
                                        _buildDatePicker(
                                          label: 'Tanggal Selesai',
                                          date: _endDate,
                                          onTap: () => _pickDate(false),
                                          errorText: provider.fieldErrors['end_date']?.first,
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
                                          errorText: provider.fieldErrors['start_date']?.first,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildDatePicker(
                                          label: 'Tanggal Selesai',
                                          date: _endDate,
                                          onTap: () => _pickDate(false),
                                          errorText: provider.fieldErrors['end_date']?.first,
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
                                'Semua dokumen wajib berformat PDF (maks 2MB per file)',
                                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 20),
                               _buildFilePicker(
                                label: 'Scan KTP (PDF)',
                                file: _ktp,
                                onPick: () => _pickFile('ktp'),
                                isRequired: true,
                                errorText: provider.fieldErrors['ktp']?.first,
                              ),
                              _buildFilePicker(
                                label: 'File Proposal (Wajib PDF)',
                                file: _file,
                                onPick: () => _pickFile('file'),
                                isRequired: true,
                                errorText: provider.fieldErrors['file']?.first,
                              ),
                              _buildFilePicker(
                                label: 'Surat Pengajuan (Wajib PDF)',
                                file: _applLetter,
                                onPick: () => _pickFile('appl_letter'),
                                isRequired: true,
                                errorText: provider.fieldErrors['appl_letter']?.first,
                              ),
                              _buildFilePicker(
                                label: 'Surat Rundown / Kegiatan (Wajib PDF)',
                                file: _actvLetter,
                                onPick: () => _pickFile('actv_letter'),
                                isRequired: true,
                                errorText: provider.fieldErrors['actv_letter']?.first,
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
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
    Function(String)? onChanged,
    String? Function(String?)? validator,
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
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          validator: validator,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF1461D2), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14), 
              borderSide: BorderSide(color: errorText != null ? Colors.red : const Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14), 
              borderSide: BorderSide(color: errorText != null ? Colors.red : const Color(0xFF1461D2), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            errorText: errorText,
            errorStyle: const TextStyle(height: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required int? value,
    required List<ContentModel> items,
    required Function(int?) onChanged,
    required IconData icon,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
        ),
        DropdownButtonFormField<int>(
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF1461D2), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14), 
              borderSide: BorderSide(color: errorText != null ? Colors.red : const Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14), 
              borderSide: BorderSide(color: errorText != null ? Colors.red : const Color(0xFF1461D2), width: 1.5),
            ),
            errorText: errorText,
            errorStyle: const TextStyle(height: 0.8),
          ),
          items: items.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    String? errorText,
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
              border: Border.all(color: errorText != null ? Colors.red : const Color(0xFFE2E8F0)),
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
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(errorText, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildFilePicker({
    required String label,
    required PlatformFile? file,
    required VoidCallback onPick,
    bool isRequired = false,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pressable(
            onTap: onPick,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: file != null ? const Color(0xFFF0F9FF) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: errorText != null ? Colors.red : (file != null ? const Color(0xFF1461D2) : const Color(0xFFE2E8F0)),
                  width: (file != null || errorText != null) ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    file != null ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
                    color: errorText != null ? Colors.red : const Color(0xFF1461D2),
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
                            isRequired ? 'Wajib (Format PDF)' : 'Opsional (Format PDF)',
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
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 4),
              child: Text(errorText, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

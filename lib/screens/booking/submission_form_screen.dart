import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/data_provider.dart';
import '../auth/login_screen.dart';

class SubmissionFormScreen extends StatefulWidget {
  const SubmissionFormScreen({super.key});
  @override
  State<SubmissionFormScreen> createState() => _SubmissionFormScreenState();
}

class _SubmissionFormScreenState extends State<SubmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namePicCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _vendorCtrl = TextEditingController();
  final _eventNameCtrl = TextEditingController();
  String? _selectedLocation;
  DateTime? _startDate;
  DateTime? _endDate;
  PlatformFile? _file;
  PlatformFile? _ktp;
  PlatformFile? _applLetter;
  PlatformFile? _actvLetter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<DataProvider>(context, listen: false).fetchLocationOptions());
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
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
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
      context: context, initialDate: DateTime.now(),
      firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => isStart ? _startDate = picked : _endDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ktp == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('KTP wajib diunggah'))); return; }
    if (_startDate == null || _endDate == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tanggal wajib diisi'))); return; }

    final formData = <String, dynamic>{
      'namePIC': _namePicCtrl.text,
      'no_hp': _noHpCtrl.text,
      'address': _addressCtrl.text,
      'vendor': _vendorCtrl.text,
      'location': _selectedLocation,
      'start_date': _startDate!.toIso8601String().split('T')[0],
      'end_date': _endDate!.toIso8601String().split('T')[0],
      'name_event': _eventNameCtrl.text,
      'ktp': MultipartFile.fromFileSync(_ktp!.path!, filename: _ktp!.name),
    };
    if (_file != null) formData['file'] = MultipartFile.fromFileSync(_file!.path!, filename: _file!.name);
    if (_applLetter != null) formData['appl_letter'] = MultipartFile.fromFileSync(_applLetter!.path!, filename: _applLetter!.name);
    if (_actvLetter != null) formData['actv_letter'] = MultipartFile.fromFileSync(_actvLetter!.path!, filename: _actvLetter!.name);

    final data = Provider.of<DataProvider>(context, listen: false);
    final success = await data.submitBooking(formData);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengajuan berhasil dikirim!'), backgroundColor: AppTheme.successColor));
      Navigator.pop(context);
    } else if (mounted && data.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data.errorMessage!), backgroundColor: AppTheme.errorColor));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Form Pengajuan Sewa')),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.lock_outline, size: 64, color: AppTheme.textLight),
          const SizedBox(height: 16),
          const Text('Silakan login terlebih dahulu'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), child: const Text('Login')),
        ])),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Form Pengajuan Sewa')),
      body: Consumer<DataProvider>(builder: (context, data, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Pengajuan Sewa Tempat', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Isi data berikut untuk mengajukan sewa', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              TextFormField(controller: _namePicCtrl, decoration: const InputDecoration(labelText: 'Nama PIC', prefixIcon: Icon(Icons.person_outlined)), validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 14),
              TextFormField(controller: _noHpCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'No. HP', prefixIcon: Icon(Icons.phone_outlined)), validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 14),
              TextFormField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Alamat', prefixIcon: Icon(Icons.home_outlined)), validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 14),
              TextFormField(controller: _vendorCtrl, decoration: const InputDecoration(labelText: 'Vendor / Instansi', prefixIcon: Icon(Icons.business_outlined)), validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 14),
              // Location dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedLocation,
                decoration: const InputDecoration(labelText: 'Lokasi', prefixIcon: Icon(Icons.location_on_outlined)),
                items: data.locationOptions.map((l) => DropdownMenuItem(value: l.name, child: Text(l.name))).toList(),
                onChanged: (v) => setState(() => _selectedLocation = v),
                validator: (v) => v == null ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(controller: _eventNameCtrl, decoration: const InputDecoration(labelText: 'Nama Kegiatan', prefixIcon: Icon(Icons.event_outlined)), validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 14),
              // Date pickers
              Row(children: [
                Expanded(child: _buildDateField('Tanggal Mulai', _startDate, () => _pickDate(true))),
                const SizedBox(width: 12),
                Expanded(child: _buildDateField('Tanggal Selesai', _endDate, () => _pickDate(false))),
              ]),
              const SizedBox(height: 20),
              // File uploads
              Text('Dokumen', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _buildFilePicker('Proposal (PDF, opsional)', _file, () => _pickFile('file')),
              _buildFilePicker('KTP (PDF, wajib) *', _ktp, () => _pickFile('ktp')),
              _buildFilePicker('Surat Pengajuan (PDF, opsional)', _applLetter, () => _pickFile('appl_letter')),
              _buildFilePicker('Surat Kegiatan (PDF, opsional)', _actvLetter, () => _pickFile('actv_letter')),
              const SizedBox(height: 24),
              SizedBox(height: 52, child: ElevatedButton(
                onPressed: data.isLoading ? null : _submit,
                child: data.isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Kirim Pengajuan', style: TextStyle(fontSize: 16)),
              )),
              const SizedBox(height: 40),
            ]),
          ),
        );
      }),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.calendar_today, size: 18)),
        child: Text(date != null ? '${date.day}/${date.month}/${date.year}' : 'Pilih tanggal', style: TextStyle(color: date != null ? AppTheme.textPrimary : AppTheme.textLight)),
      ),
    );
  }

  Widget _buildFilePicker(String label, PlatformFile? file, VoidCallback onPick) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton.icon(
        onPressed: onPick,
        icon: Icon(file != null ? Icons.check_circle : Icons.upload_file, size: 18, color: file != null ? AppTheme.successColor : null),
        label: Text(file?.name ?? label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: file != null ? AppTheme.successColor : null)),
        style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14)),
      ),
    );
  }
}

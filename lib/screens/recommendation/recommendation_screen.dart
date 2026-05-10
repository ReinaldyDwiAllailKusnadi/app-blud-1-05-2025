import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/recommendation_provider.dart';
import '../../models/recommendation_model.dart';
import '../../core/widgets/app_inputs.dart';
import '../booking/submission_form_screen.dart';
import '../../core/widgets/main_tab_header.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _eventTypeController = TextEditingController();
  final _participantsController = TextEditingController();
  final _budgetController = TextEditingController();
  final _facilitiesController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedPreference;

  @override
  void dispose() {
    _eventTypeController.dispose();
    _participantsController.dispose();
    _budgetController.dispose();
    _facilitiesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.navBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSearch() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal kegiatan')),
      );
      return;
    }

    final participants = int.tryParse(_participantsController.text);
    final budget = double.tryParse(_budgetController.text);
    
    List<String>? facilities;
    if (_facilitiesController.text.isNotEmpty) {
      facilities = _facilitiesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    context.read<RecommendationProvider>().fetchRecommendations(
      eventType: _eventTypeController.text.isEmpty ? null : _eventTypeController.text,
      participants: participants,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      budget: budget,
      facilities: facilities,
      preference: _selectedPreference,
    );
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return 'Hubungi Admin';
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          const MainTabHeader(title: 'Rekomendasi Lokasi'),
          Expanded(
            child: Consumer<RecommendationProvider>(
              builder: (context, provider, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormCard(),
                      const SizedBox(height: 24),
                      if (provider.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (provider.errorMessage != null)
                        _buildErrorState(provider.errorMessage!)
                      else if (provider.recommendations.isNotEmpty)
                        _buildResultsList(provider.recommendations)
                      else
                        _buildEmptyState(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune_rounded, color: AppTheme.navBlue, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cari Lokasi Sesuai Kebutuhan',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Lengkapi informasi kegiatan Anda untuk mendapatkan rekomendasi terbaik.',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            AppTextField(
              label: 'Jenis Kegiatan',
              controller: _eventTypeController,
              hint: 'Contoh: seminar, bazar, outbound',
              icon: Icons.event_available_rounded,
            ),
            const SizedBox(height: 18),

            AppTextField(
              label: 'Jumlah Peserta',
              controller: _participantsController,
              keyboardType: TextInputType.number,
              hint: 'Contoh: 150',
              icon: Icons.groups_outlined,
            ),
            const SizedBox(height: 18),

            AppDateField(
              label: 'Tanggal Kegiatan *',
              date: _selectedDate,
              onTap: () => _selectDate(context),
              icon: Icons.calendar_month_rounded,
            ),
            const SizedBox(height: 18),

            AppTextField(
              label: 'Budget (Rp)',
              controller: _budgetController,
              keyboardType: TextInputType.number,
              hint: 'Contoh: 2000000',
              icon: Icons.payments_outlined,
            ),
            const SizedBox(height: 18),

            AppTextField(
              label: 'Fasilitas Dibutuhkan',
              controller: _facilitiesController,
              hint: 'Contoh: aula, kursi, sound system',
              icon: Icons.check_circle_outline_rounded,
            ),
            const SizedBox(height: 18),

            AppDropdownField(
              label: 'Preferensi Lokasi',
              value: _selectedPreference,
              items: const ['indoor', 'outdoor'],
              hint: 'Pilih Preferensi Lokasi',
              icon: Icons.category_outlined,
              onChanged: (val) => setState(() => _selectedPreference = val),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Cari Rekomendasi',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(List<RecommendationModel> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppTheme.accentColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Hasil Rekomendasi',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...results.map((item) => _buildRecommendationCard(item)),
      ],
    );
  }

  Widget _buildRecommendationCard(RecommendationModel item) {
    final statusColor = _getStatusColor(item.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: item.available ? Colors.white : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.available ? AppTheme.dividerColor : Colors.grey.shade300,
        ),
        boxShadow: [
          if (item.available)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Score
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.status,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.navBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    children: [
                      Text(
                        item.score.toStringAsFixed(0),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.navBlue,
                        ),
                      ),
                      Text(
                        'score',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.navBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Details Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.payments_outlined, 'Harga Sewa', _formatCurrency(item.price)),
                _buildInfoRow(Icons.groups_outlined, 'Kapasitas', '${item.capacity ?? "-"} orang'),
                _buildInfoRow(Icons.category_outlined, 'Tipe Area', '${item.venueType ?? "-"} (${item.isIndoor ? "Indoor" : ""} ${item.isOutdoor ? "Outdoor" : ""})'),
                
                if (item.matchedFacilities.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Fasilitas Cocok:',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: item.matchedFacilities.map((f) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Text(
                        f,
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.blue.shade800, fontWeight: FontWeight.w500),
                      ),
                    )).toList(),
                  ),
                ],

                const SizedBox(height: 16),
                Text(
                  'Mengapa direkomendasikan?',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 6),
                ...item.reasons.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppTheme.successColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r,
                          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                )),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: item.available 
                      ? () {
                          // TODO: prefill lokasi pengajuan berdasarkan hasil rekomendasi.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubmissionFormScreen(
                                prefilledLocation: item.name,
                                prefilledDate: _selectedDate,
                              ),
                            ),
                          );
                        }
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.available ? AppTheme.navBlue : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(item.available ? 'Ajukan Sewa' : 'Tidak Tersedia'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 16, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                children: [
                  TextSpan(text: '$label: '),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Sangat Direkomendasikan': return Colors.green;
      case 'Direkomendasikan': return AppTheme.navBlue;
      case 'Cukup Sesuai': return Colors.orange;
      case 'Kurang Direkomendasikan': return Colors.grey;
      case 'Tidak Tersedia': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Belum ada rekomendasi',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Isi kebutuhan kegiatan Anda pada form di atas.',
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, size: 60, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              error.contains('401') ? 'Sesi Anda berakhir. Silakan login kembali.' : error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

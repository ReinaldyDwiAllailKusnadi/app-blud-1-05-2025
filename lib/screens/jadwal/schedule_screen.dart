import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../core/widgets/skeleton.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_layout.dart';
import '../../core/widgets/app_states.dart';

import '../../core/widgets/main_tab_header.dart';

// Schedule Screen - Updated: 2026-05-14 22:45 (Specific Date Filtering)
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String? _selectedLocation = 'Semua Lokasi';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchJadwal();
    });
  }

  bool _isDateOnSchedule(DateTime selected, String? startStr, String? endStr) {
    if (startStr == null || startStr == '-' || startStr.isEmpty) return false;
    
    final selectedOnly = DateTime(selected.year, selected.month, selected.day);
    final start = DateTime.tryParse(startStr);
    if (start == null) return false;
    final startOnly = DateTime(start.year, start.month, start.day);
    
    DateTime endOnly;
    if (endStr == null || endStr == '-' || endStr.isEmpty) {
      endOnly = startOnly;
    } else {
      final end = DateTime.tryParse(endStr);
      if (end == null) {
        endOnly = startOnly;
      } else {
        endOnly = DateTime(end.year, end.month, end.day);
      }
    }

    return !selectedOnly.isBefore(startOnly) && !selectedOnly.isAfter(endOnly);
  }

  String _formatIndonesianDate(String? date) {
    if (date == null || date.isEmpty || date == '-') return 'Tanggal belum tersedia';

    try {
      final parsed = DateTime.tryParse(date);
      if (parsed == null) return date;

      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];

      return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
    } catch (e) {
      return date;
    }
  }

  String _formatDateRange(String? start, String? end) {
    final startText = _formatIndonesianDate(start);
    if (end == null || end.isEmpty || end == '-' || end == start) return startText;
    return '$startText - ${_formatIndonesianDate(end)}';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            const MainTabHeader(title: 'Jadwal Lokasi'),
            Expanded(
              child: Consumer<EventProvider>(
                builder: (context, prov, _) {
                  // Filter Logic
                  final filteredEvents = prov.events.where((event) {
                    // Filter Location
                    bool matchesLocation = _selectedLocation == 'Semua Lokasi' || 
                                         event.location == _selectedLocation;
                    
                    // Filter Specific Date (is selectedDate between start and end)
                    bool matchesDate = _isDateOnSchedule(_selectedDate, event.startDate, event.endDate);
                    
                    return matchesLocation && matchesDate;
                  }).toList();

                  // Get Unique Locations for Filter
                  final uniqueLocations = ['Semua Lokasi', ...prov.events.map((e) => e.location ?? '-').where((l) => l != '-').toSet()];

                  return RefreshIndicator(
                    onRefresh: () => prov.fetchJadwal(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header & Subtitle
                          const AppSectionTitle(title: 'Kalender Kegiatan'),
                          const SizedBox(height: 4),
                          Text(
                            'Cek jadwal penggunaan lokasi sebelum mengajukan sewa.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          
                          const SizedBox(height: 24),

                          // Filters Row
                          Row(
                            children: [
                              // Location Filter
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedLocation,
                                      isExpanded: true,
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.navBlue),
                                      items: uniqueLocations.map((loc) => DropdownMenuItem(
                                        value: loc,
                                        child: Text(loc, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                      )).toList(),
                                      onChanged: (val) => setState(() => _selectedLocation = val),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Date Picker
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  onTap: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                      helpText: 'PILIH TANGGAL CEK JADWAL',
                                    );
                                    if (picked != null) {
                                      setState(() => _selectedDate = picked);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _formatIndonesianDate(_selectedDate.toString().split(' ')[0]),
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.navBlue),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(Icons.calendar_month_rounded, size: 18, color: AppTheme.navBlue),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          
                          if (prov.isLoading && prov.events.isEmpty)
                            Column(
                              children: List.generate(3, (index) => const Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: Skeleton(width: double.infinity, height: 100, borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusLg))),
                              )),
                            )
                          else if (filteredEvents.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: AppEmptyState(
                                title: 'Tidak Ada Jadwal', 
                                subtitle: 'Tidak ada jadwal pada tanggal ${_formatIndonesianDate(_selectedDate.toString().split(' ')[0])}. Kamu bisa memilih tanggal lain atau melanjutkan pengajuan dari halaman destinasi.',
                                icon: Icons.event_available_rounded,
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredEvents.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final event = filteredEvents[index];
                                return _FilledScheduleCard(
                                  title: event.nameEvent,
                                  vendor: event.vendor ?? '-',
                                  location: event.location ?? '-',
                                  dateRange: _formatDateRange(event.startDate, event.endDate),
                                  status: 'Terisi',
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledScheduleCard extends StatelessWidget {
  final String title;
  final String vendor;
  final String location;
  final String dateRange;
  final String status;

  const _FilledScheduleCard({
    required this.title,
    required this.vendor,
    required this.location,
    required this.dateRange,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.navBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_note_rounded, color: AppTheme.navBlue, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w800, 
                        color: AppTheme.textPrimary, 
                        height: 1.2
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.business_rounded, size: 14, color: AppTheme.textLight),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            vendor,
                            style: const TextStyle(
                              fontSize: 13, 
                              fontWeight: FontWeight.w600, 
                              color: AppTheme.textSecondary
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.navBlue),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              fontSize: 13, 
                              fontWeight: FontWeight.w700, 
                              color: AppTheme.textPrimary
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 13, color: AppTheme.textLight),
                        const SizedBox(width: 6),
                        Text(
                          dateRange,
                          style: const TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.w500, 
                            color: AppTheme.textSecondary
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../booking/submission_form_screen.dart';
import '../../core/widgets/skeleton.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_layout.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_states.dart';

// Schedule Screen - Updated: 2026-05-07 20:02 (Force Rebuild)
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchJadwal();
    });
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // ── Main Content Area ──
          Column(
            children: [
              const AppGradientHeader(title: 'Jadwal & Sewa Lokasi'),
              Expanded(
                child: Consumer<EventProvider>(
                  builder: (context, prov, _) {
                    return RefreshIndicator(
                      onRefresh: () => prov.fetchJadwal(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 160),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section 1: Jadwal Terisi
                              const AppSectionTitle(title: 'Jadwal Terisi'),
                              const SizedBox(height: 20),
                              
                              if (prov.isLoading && prov.events.isEmpty)
                                Column(
                                  children: List.generate(3, (index) => const Padding(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: Skeleton(width: double.infinity, height: 100, borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusLg))),
                                  )),
                                )
                              else if (prov.events.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: AppEmptyState(
                                    title: 'Belum Ada Jadwal', 
                                    subtitle: 'Seluruh lokasi masih tersedia untuk disewa.',
                                    icon: Icons.calendar_today_rounded,
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: prov.events.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final event = prov.events[index];
                                    return _FilledScheduleCard(
                                      title: event.nameEvent,
                                      vendor: event.vendor ?? '-',
                                      location: event.location ?? '-',
                                      dateRange: _formatDateRange(event.startDate, event.endDate),
                                      fileUrl: event.fileUrl,
                                    );
                                  },
                                ),

                              const SizedBox(height: 40),
                              const Divider(),
                              const SizedBox(height: 32),

                              // Section 2: Aturan & Alur Penyewaan
                              const AppSectionTitle(title: 'Aturan & Alur Penyewaan'),
                              const SizedBox(height: 24),
                              const _RentalStepTimeline(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          // Sticky Bottom Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _StickyRentButton(),
          ),
        ],
      ),
    );
  }
}

class _FilledScheduleCard extends StatelessWidget {
  final String title;
  final String vendor;
  final String location;
  final String dateRange;
  final String? fileUrl;

  const _FilledScheduleCard({
    required this.title,
    required this.vendor,
    required this.location,
    required this.dateRange,
    this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      color: const Color(0xFFEAF6FF),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppTheme.navBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.textLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$location • $vendor',
                        style: const TextStyle(
                          fontSize: 13, 
                          fontWeight: FontWeight.w600, 
                          color: AppTheme.textSecondary
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textLight),
                    const SizedBox(width: 4),
                    Text(
                      dateRange,
                      style: const TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.w500, 
                        color: AppTheme.textSecondary
                      ),
                    ),
                  ],
                ),
                if (fileUrl != null && fileUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 38,
                    child: AppSecondaryButton(
                      text: 'Lihat Rundown',
                      height: 38,
                      icon: Icons.description_outlined,
                      onTap: () async {
                        final uri = Uri.parse(fileUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RentalStepTimeline extends StatelessWidget {
  const _RentalStepTimeline();

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Cek ketersediaan lokasi',
      'Pilih tanggal & ajukan sewa',
      'Verifikasi admin',
      'Lakukan pembayaran',
      'Konfirmasi & dapatkan izin',
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.blueHeaderGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 13, 
                          fontWeight: FontWeight.w800
                        ),
                      ),
                    ),
                  ),
                  if (index != steps.length - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: AppTheme.navBlue.withValues(alpha: 0.2),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    steps[index],
                    style: const TextStyle(
                      fontSize: 15, 
                      fontWeight: FontWeight.w600, 
                      color: AppTheme.textPrimary
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StickyRentButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 20, 
            offset: const Offset(0, -5)
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: AppPrimaryButton(
            text: 'SEWA SEKARANG!',
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const SubmissionFormScreen())
              );
            },
          ),
        ),
      ),
    );
  }
}

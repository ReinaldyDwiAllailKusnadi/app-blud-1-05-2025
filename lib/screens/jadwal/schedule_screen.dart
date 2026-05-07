import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../booking/submission_form_screen.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/skeleton.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main Content Area ──
            Column(
              children: [
                const _ScheduleHeader(),
                Expanded(
                  child: Consumer<EventProvider>(
                    builder: (context, prov, _) {
                      return RefreshIndicator(
                        onRefresh: () => prov.fetchJadwal(),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 120),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section 1: Jadwal Terisi
                                Text(
                                  'Jadwal Terisi',
                                  style: GoogleFonts.inter(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (prov.isLoading && prov.events.isEmpty)
                                  Column(
                                    children: List.generate(5, (index) => const Padding(
                                      padding: EdgeInsets.only(bottom: 16),
                                      child: CardSkeleton(),
                                    )),
                                  )
                                else if (prov.events.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    child: Center(child: Text('Belum ada jadwal terisi')),
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: prov.events.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 14),
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

                                const SizedBox(height: 28),
                                const Divider(color: Color(0xFFE7E7E7), thickness: 1),
                                const SizedBox(height: 28),

                                // Section 2: Aturan & Alur Penyewaan
                                Text(
                                  'Aturan & Alur Penyewaan',
                                  style: GoogleFonts.inter(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                    letterSpacing: -0.5,
                                  ),
                                ),
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
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _GradientRentButton(),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Header Widget
// ═══════════════════════════════════════════════════════════
class _ScheduleHeader extends StatelessWidget {
  const _ScheduleHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(color: Colors.white),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0A81DE), size: 28),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Jadwal & Sewa Lokasi',
              style: GoogleFonts.inter(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Filled Schedule Card
// ═══════════════════════════════════════════════════════════
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
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBF5FC).withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFF1AA0EC),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$location • $vendor',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateRange,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF444444),
                  ),
                ),
                if (fileUrl != null && fileUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final uri = Uri.parse(fileUrl!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1AA0EC)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.description_outlined, size: 16, color: Color(0xFF1AA0EC)),
                          const SizedBox(width: 6),
                          Text(
                            'Lihat Rundown',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1AA0EC),
                            ),
                          ),
                        ],
                      ),
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

// ═══════════════════════════════════════════════════════════
// Rental Step Timeline
// ═══════════════════════════════════════════════════════════
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

    return Stack(
      children: [
        // Connecting Line
        Positioned(
          left: 15.5,
          top: 16,
          bottom: 16,
          child: Container(
            width: 2.5,
            decoration: BoxDecoration(
              color: const Color(0xFF1FA0E7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Steps
        Column(
          children: List.generate(steps.length, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: index == steps.length - 1 ? 0 : 26),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1FA0E7),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    steps[index],
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF111111),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Gradient Rent Button
// ═══════════════════════════════════════════════════════════
class _GradientRentButton extends StatelessWidget {
  const _GradientRentButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.0),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Pressable(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubmissionFormScreen()),
          );
        },
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF20A8F4), Color(0xFF142B9A)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF142B9A).withValues(alpha: 0.25),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'SEWA SEKARANG!',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


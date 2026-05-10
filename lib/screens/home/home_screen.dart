import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/content_provider.dart';
import '../../providers/event_provider.dart';
import '../wisata/destination_detail_screen.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../booking/submission_history_screen.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/skeleton.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSeeAllSchedule;
  final VoidCallback? onGoToRecommendation;
  const HomeScreen({super.key, this.onSeeAllSchedule, this.onGoToRecommendation});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data saat screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().fetchHomeData();
      context.read<EventProvider>().fetchJadwal();
    });
  }

  String _shortLocation(String value) {
    if (value.isEmpty) return '-';
    return value.split(',').first.trim();
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer2<ContentProvider, EventProvider>(
        builder: (context, contentProv, eventProv, _) {
          if (contentProv.isLoading && contentProv.featuredContents.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await contentProv.fetchHomeData();
              await eventProv.fetchJadwal();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Blue Header ──
                  _buildHeader(context),

                  const SizedBox(height: 32),

                  // ── Destination Section ──
                  _buildSectionTitle('Destinasi Unggulan'),
                  const SizedBox(height: 16),
                  _buildDestinationSection(contentProv),

                  const SizedBox(height: 32),

                  // ── Event Section ──
                  _buildEventSection(eventProv),

                  const SizedBox(height: 32),

                  // ── Recommendation Section ──
                  _buildRecommendationSection(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.pureBlack,
              letterSpacing: -0.5,
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'Lihat semua',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepPurple,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Rekomendasi Lokasi'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Pressable(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onGoToRecommendation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF9FAFB), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentColor, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bingung memilih lokasi?',
                          style: GoogleFonts.inter(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Temukan lokasi sewa sesuai kebutuhan kegiatan Anda.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF444444),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight, size: 28),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 32),
      decoration: const BoxDecoration(
        gradient: AppTheme.blueHeaderGradient,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang di',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Text(
                'BLUD Pariwisata',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          // Menu Button
          _buildHeaderMenu(context),
        ],
      ),
    );
  }

  Widget _buildHeaderMenu(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.white,
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      offset: const Offset(0, 52),
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.menu_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      onSelected: (value) {
        if (value == 'history') {
          final auth = context.read<AuthProvider>();
          if (!auth.isAuthenticated) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SubmissionHistoryScreen(),
            ),
          );
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'history',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.navBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.history_rounded, size: 20, color: AppTheme.navBlue),
              ),
              const SizedBox(width: 14),
              Text(
                'Riwayat Pengajuan',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationSection(ContentProvider prov) {
    if (prov.isLoading) {
      return SizedBox(
        height: 255,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, __) => const Skeleton(width: 200, height: 255, borderRadius: BorderRadius.all(Radius.circular(20))),
        ),
      );
    }

    if (prov.featuredContents.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('Tidak ada destinasi unggulan')),
      );
    }

    return SizedBox(
      height: 255,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: prov.featuredContents.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final dest = prov.featuredContents[index];
          return _DestinationCard(
            title: dest.name,
            location: _shortLocation(dest.location ?? 'Purwokerto'),
            imageUrl: dest.imageUrl ?? '',
            slug: dest.slug,
          );
        },
      ),
    );
  }

  Widget _buildEventSection(EventProvider prov) {
    return Column(
      children: [
        _buildSectionTitle(
          'Jadwal Event Terkini',
          onSeeAll: widget.onSeeAllSchedule,
        ),
        const SizedBox(height: 16),
        if (prov.isLoading && prov.events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: List.generate(2, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    const Skeleton(width: 60, height: 60, borderRadius: BorderRadius.all(Radius.circular(16))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Skeleton(width: double.infinity, height: 20),
                          SizedBox(height: 8),
                          Skeleton(width: 150, height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ),
          )
        else if (prov.events.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(child: Text('Belum ada jadwal event terbaru')),
          )
        else
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: prov.events.length > 2 ? 2 : prov.events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final event = prov.events[index];
              return _EventCard(
                title: event.nameEvent,
                location: event.location ?? '-',
                date: _formatDateRange(event.startDate, event.endDate),
                iconColor: index % 2 == 0 ? const Color(0xFF1A9AEF) : null,
                gradient: index % 2 != 0 ? const LinearGradient(
                  colors: [Color(0xFF5D8FE8), Color(0xFF604DEC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ) : null,
              );
            },
          ),
      ],
    );
  }
}


class _DestinationCard extends StatelessWidget {
  final String title;
  final String location;
  final String imageUrl;
  final String slug;

  const _DestinationCard({
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.slug,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DestinationDetailScreen(slug: slug),
          ),
        );
      },
      child: Container(
      width: 185,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported_rounded, color: Colors.white),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: const Alignment(0, -0.2),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _EventCard extends StatelessWidget {
  final String title;
  final String location;
  final String date;
  final Color? iconColor;
  final Gradient? gradient;

  const _EventCard({
    required this.title,
    required this.location,
    required this.date,
    this.iconColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        // Option: Navigate to schedule detail if available
      },
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF9FAFB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor,
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: (iconColor ?? Colors.blue).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF444444),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF444444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}


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
  const HomeScreen({super.key, this.onSeeAllSchedule});

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
      body: Stack(
        children: [
          // ── Main Scrollable Content ──
          Positioned.fill(
            child: Consumer2<ContentProvider, EventProvider>(
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
                        // ── Blue Gradient Header ──
                        _buildHeader(context),

                        // ── Destination Cards (Overlapping) ──
                        Transform.translate(
                          offset: const Offset(0, -88),
                          child: _buildDestinationSection(contentProv),
                        ),

                        // ── Event Section ──
                        Transform.translate(
                          offset: const Offset(0, -60),
                          child: _buildEventSection(eventProv),
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 130),
      decoration: BoxDecoration(
        gradient: AppTheme.blueHeaderGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang di',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    'BLUD Pariwisata',
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              // Menu Button (Popup)
              PopupMenuButton<String>(
                color: Colors.white,
                elevation: 12,
                shadowColor: Colors.black.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                offset: const Offset(0, 52),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 28,
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
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.history_rounded, size: 20, color: Color(0xFF3B82F6)),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Riwayat Pengajuan',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 22),
                const SizedBox(width: 12),
                Text(
                  'Cari destinasi wisata...',
                  style: GoogleFonts.inter(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Text(
            'Destinasi Unggulan',
            style: GoogleFonts.inter(
              fontSize: 21.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
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
        height: 255,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Jadwal Event Terkini',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.pureBlack,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: widget.onSeeAllSchedule,
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
          const SizedBox(height: 20),
          if (prov.isLoading && prov.events.isEmpty)
            Column(
              children: List.generate(3, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    const Skeleton(width: 80, height: 80, borderRadius: BorderRadius.all(Radius.circular(16))),
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
            )
          else if (prov.events.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: Text('Belum ada jadwal event terbaru')),
            )
          else
            ListView.separated(
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
      ),
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


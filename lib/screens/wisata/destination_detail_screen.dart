import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../providers/content_provider.dart';
import '../../models/content_model.dart';
import '../booking/submission_form_screen.dart';

class DestinationDetailScreen extends StatefulWidget {
  final String slug;
  const DestinationDetailScreen({super.key, required this.slug});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  ContentModel? _detail;
  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final result = await context.read<ContentProvider>().fetchWisataDetail(widget.slug);
    if (mounted) {
      setState(() {
        _detail = result;
        _isInitLoading = false;
      });
    }
  }

  String _formatCurrency(String? price) {
    if (price == null || price.isEmpty || price == '-') return '-';
    try {
      final cleanPrice = price.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanPrice.isEmpty) return '-';
      final value = int.parse(cleanPrice);
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      ).format(value).replaceAll(',', '.');
    } catch (e) {
      return price;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    final dest = _detail!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Scrollable Content ──
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                // 1. Hero Image
                _buildHeroImage(context, dest.imageUrl ?? ''),

                // 2. Content Card (Overlap)
                Transform.translate(
                  offset: const Offset(0, -32),
                  child: _buildContentCard(dest),
                ),
              ],
            ),
          ),

          // 3. Top Action Buttons (Fixed on top of Image)
          _buildTopActions(context),

          // 4. Sticky Bottom CTA Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomCtaBar(dest: dest),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, String imageUrl) {
    return SizedBox(
      height: 390,
      width: double.infinity,
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
                child: const Icon(Icons.image_not_supported, size: 50, color: Colors.white),
              ),
            ),
          ),
          // Subtle Dark Overlay for visibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopActions(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPadding + 10,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _TopCircleButton(
            icon: Icons.chevron_left_rounded,
            onTap: () => Navigator.pop(context),
          ),
          _TopCircleButton(
            icon: Icons.share_rounded,
            onTap: () {
              // TODO: Implement Share
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(ContentModel dest) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dest.name,
            style: GoogleFonts.inter(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),

          // Info Section (Responsive Wrap)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildInfoItem(
                icon: Icons.location_on_rounded,
                label: 'Lokasi',
                value: dest.location ?? 'Purwokerto, Banyumas',
                width: (MediaQuery.of(context).size.width - 60) / 2, // 2 items per row if space allows
              ),
              _buildInfoItem(
                icon: Icons.access_time_filled_rounded,
                label: 'Buka',
                value: '${dest.openTime ?? '08:00'} - ${dest.closeTime ?? '22:00'} WIB',
                width: (MediaQuery.of(context).size.width - 60) / 2,
              ),
              _buildInfoItem(
                icon: Icons.payments_rounded,
                label: 'Mulai dari',
                value: _formatCurrency(dest.priceWeekday),
                width: (MediaQuery.of(context).size.width - 60) / 2,
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 24),

          Text(
            'Deskripsi',
            style: GoogleFonts.inter(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            dest.description ?? 'Belum ada deskripsi untuk destinasi ini.',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1F2937),
              height: 1.6,
            ),
          ),

          const SizedBox(height: 32),
          
          // Map Preview
          _MapPreview(
            onTap: () => _openMap(dest),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    double? width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3B82F6)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _extractIframeSrc(String? iframe) {
    if (iframe == null || iframe.trim().isEmpty) return null;

    final regex = RegExp(r'src="([^"]+)"');
    final match = regex.firstMatch(iframe);

    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    return iframe;
  }

  Future<void> _openMap(ContentModel destination) async {
    final embedUrl = _extractIframeSrc(destination.locationEmbed);

    final fallbackQuery = Uri.encodeComponent(
      '${destination.name} ${destination.location}',
    );

    final fallbackUrl = 'https://www.google.com/maps/search/?api=1&query=$fallbackQuery';

    final url = (embedUrl != null && embedUrl.isNotEmpty && embedUrl.startsWith('http'))
        ? embedUrl
        : fallbackUrl;

    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        final fallbackUri = Uri.parse(fallbackUrl);
        await launchUrl(
          fallbackUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka peta')),
        );
      }
    }
  }
}


class _TopCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ColorFilter.mode(Colors.black.withValues(alpha: 0.1), BlendMode.dstIn),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}


class _MapPreview extends StatelessWidget {
  final VoidCallback onTap;
  const _MapPreview({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Stack(
          children: [
            // Minimalist Map Background
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Center(
                  child: Icon(Icons.map_rounded, color: Colors.blue.shade700, size: 80),
                ),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded, size: 20, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    Text(
                      'Lihat di Peta',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomCtaBar extends StatelessWidget {
  final ContentModel dest;
  const _BottomCtaBar({required this.dest});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Booking Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubmissionFormScreen(
                      prefilledLocation: dest.name,
                      prefilledLocationId: dest.id,
                      prefilledLocationSlug: dest.slug,
                    ),
                  ),
                );
              },
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF20A8F4), Color(0xFF142B9A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF142B9A).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Booking Sekarang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

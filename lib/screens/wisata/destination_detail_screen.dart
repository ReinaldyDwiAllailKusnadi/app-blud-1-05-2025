import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/content_provider.dart';
import '../../models/content_model.dart';

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
            child: _BottomCtaBar(whatsapp: dest.whatsapp),
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
          ),
          const SizedBox(height: 24),

          // Info Row (3 Columns)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.location_on_rounded,
                  title: dest.location ?? 'Purwokerto,',
                  value: 'Banyumas',
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.access_time_filled_rounded,
                  title: 'Buka',
                  value: '${dest.openTime ?? '08:00'} - ${dest.closeTime ?? '22:00'} WIB',
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.payments_rounded, color: Color(0xFF3B82F6), size: 22),
                        SizedBox(width: 8),
                        Text('Mulai dari', style: TextStyle(fontSize: 14.5, color: Color(0xFF1F2937))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Text(
                        'Rp ${dest.priceWeekday ?? '25.000'}',
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
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
          const _MapPreview(),
        ],
      ),
    );
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

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoItem({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF3B82F6), size: 22),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 14.5, color: Color(0xFF1F2937))),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Minimalist Map Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Center(
                child: Icon(Icons.location_on_rounded, color: Colors.blue.shade700, size: 40),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map_rounded, size: 18, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(
                    'Lihat di Peta',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCtaBar extends StatelessWidget {
  final String? whatsapp;
  const _BottomCtaBar({this.whatsapp});

  Future<void> _launchWhatsApp() async {
    if (whatsapp == null || whatsapp!.isEmpty) return;
    
    // Format number: ensure it starts with 62
    String phone = whatsapp!.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    } else if (phone.startsWith('8')) {
      phone = '62$phone';
    }

    final url = Uri.parse("https://wa.me/$phone");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch WhatsApp");
    }
  }

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
          // WhatsApp Button (Only show if whatsapp available)
          if (whatsapp != null && whatsapp!.isNotEmpty)
            Expanded(
              flex: 45,
              child: GestureDetector(
                onTap: _launchWhatsApp,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'WhatsApp',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (whatsapp != null && whatsapp!.isNotEmpty) const SizedBox(width: 12),
          // Booking Button
          Expanded(
            flex: 55,
            child: GestureDetector(
              onTap: () {
                // TODO: Navigate to Booking Form
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F4EA3), Color(0xFF08C6D9)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Center(
                  child: Text(
                    'Pesan Tiket',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/content_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/skeleton.dart';
import 'destination_detail_screen.dart';

class DestinationListScreen extends StatefulWidget {
  const DestinationListScreen({super.key});

  @override
  State<DestinationListScreen> createState() => _DestinationListScreenState();
}

class _DestinationListScreenState extends State<DestinationListScreen> {
  String _shortLocation(String location) {
    if (location.trim().isEmpty) return '-';
    // Take first 2 parts of address for concise display
    return location.split(',').take(2).join(',').trim();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().fetchAllWisata();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // ── Main Content Area ──
          Column(
            children: [
              _GradientHeader(
                title: 'Objek Wisata Banyumas',
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: Consumer<ContentProvider>(
                  builder: (context, prov, _) {
                    if (prov.isLoading && prov.contents.isEmpty) {
                      return ListView.separated(
                        padding: const EdgeInsets.only(top: 24, bottom: 40),
                        itemCount: 5,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (_, __) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Skeleton(width: double.infinity, height: 220, borderRadius: BorderRadius.all(Radius.circular(24))),
                              SizedBox(height: 12),
                              Skeleton(width: 200, height: 24),
                              SizedBox(height: 8),
                              Skeleton(width: 150, height: 16),
                            ],
                          ),
                        ),
                      );
                    }

                    if (prov.contents.isEmpty) {
                      return const Center(child: Text('Tidak ada destinasi ditemukan'));
                    }

                    return RefreshIndicator(
                      onRefresh: () => prov.fetchAllWisata(),
                      child: ListView.separated(
                        padding: const EdgeInsets.only(top: 24, bottom: 40),
                        itemCount: prov.contents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final dest = prov.contents[index];
                          return _DestinationListCard(
                            title: dest.name,
                            description: dest.description ?? '',
                            location: _shortLocation(dest.location ?? 'Purwokerto'),
                            imageUrl: dest.imageUrl ?? '',
                            slug: dest.slug,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}


// ═══════════════════════════════════════════════════════════
// Gradient Header Widget
// ═══════════════════════════════════════════════════════════
class _GradientHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _GradientHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(10, topPadding, 10, 0),
      height: topPadding + 64,
      decoration: BoxDecoration(
        gradient: AppTheme.blueHeaderGradient,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 32),
              onPressed: onBack,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Destination Card Widget
// ═══════════════════════════════════════════════════════════
class _DestinationListCard extends StatelessWidget {
  final String title;
  final String description;
  final String location;
  final String imageUrl;
  final String slug;

  const _DestinationListCard({
    required this.title,
    required this.description,
    required this.location,
    required this.imageUrl,
    required this.slug,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DestinationDetailScreen(slug: slug),
          ),
        );
      },
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            SizedBox(
              height: 220,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade100,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 40),
                ),
              ),
            ),
            // Info Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF555555),
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Color(0xFF6B7280), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF555555),
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


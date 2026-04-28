import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/data_provider.dart';
import '../fasilitas/fasilitas_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class WisataDetailScreen extends StatefulWidget {
  final String slug;
  const WisataDetailScreen({super.key, required this.slug});
  @override
  State<WisataDetailScreen> createState() => _WisataDetailScreenState();
}

class _WisataDetailScreenState extends State<WisataDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<DataProvider>(context, listen: false).fetchWisataDetail(widget.slug));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DataProvider>(builder: (context, data, _) {
        final content = data.selectedContent;
        if (data.isLoading || content == null) return const Center(child: CircularProgressIndicator());
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: content.imageUrl != null
                    ? CachedNetworkImage(imageUrl: content.imageUrl!, fit: BoxFit.cover)
                    : Container(color: AppTheme.shimmerBase),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(content.name, style: Theme.of(context).textTheme.displayMedium),
                    const SizedBox(height: 8),
                    if (content.location != null)
                      Row(children: [
                        const Icon(Icons.location_on, size: 16, color: AppTheme.primaryColor),
                        const SizedBox(width: 6),
                        Expanded(child: Text(content.location!, style: Theme.of(context).textTheme.bodyMedium)),
                      ]),
                    const SizedBox(height: 16),
                    // Social media
                    _buildSocialRow(content),
                    const SizedBox(height: 20),
                    // Info cards
                    Row(children: [
                      _buildInfoCard(context, 'Jam Buka', '${content.openTime ?? '-'} - ${content.closeTime ?? '-'}', Icons.access_time_rounded),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      _buildInfoCard(context, 'Weekday', 'Rp ${content.priceWeekday ?? '-'}', Icons.calendar_today),
                      const SizedBox(width: 12),
                      _buildInfoCard(context, 'Weekend', 'Rp ${content.priceWeekend ?? '-'}', Icons.weekend_rounded),
                    ]),
                    const SizedBox(height: 20),
                    // Description
                    Text('Deskripsi', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(content.description ?? 'Tidak ada deskripsi', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 24),
                    // CTA
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FasilitasScreen(slug: widget.slug))),
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Info Fasilitas & Harga Sewa'),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSocialRow(dynamic content) {
    return Wrap(spacing: 8, children: [
      if (content.instagram != null && content.instagram!.isNotEmpty)
        ActionChip(label: const Text('Instagram'), avatar: const Icon(Icons.camera_alt, size: 16), onPressed: () => _openUrl(content.instagram!)),
      if (content.tiktok != null && content.tiktok!.isNotEmpty)
        ActionChip(label: const Text('TikTok'), avatar: const Icon(Icons.music_note, size: 16), onPressed: () => _openUrl(content.tiktok!)),
      if (content.whatsapp != null && content.whatsapp!.isNotEmpty)
        ActionChip(label: const Text('WhatsApp'), avatar: const Icon(Icons.chat, size: 16), onPressed: () => _openUrl('https://wa.me/${content.whatsapp}')),
    ]);
  }

  Widget _buildInfoCard(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
        ),
        child: Row(children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          )),
        ]),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/data_provider.dart';
import '../../data/models/models.dart';
import '../wisata/wisata_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<DataProvider>(context, listen: false).fetchHome());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DataProvider>(builder: (context, data, _) {
        if (data.isLoading && data.contents.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () => data.fetchHome(),
          child: CustomScrollView(
            slivers: [
              // Hero Section
              SliverToBoxAdapter(child: _buildHero(context)),
              // Wisata Section
              SliverToBoxAdapter(child: _buildSectionTitle(context, 'Objek Wisata', Icons.landscape_rounded)),
              SliverToBoxAdapter(child: _buildWisataCarousel(data.contents)),
              // News Section
              SliverToBoxAdapter(child: _buildSectionTitle(context, 'Kabar Banyumas', Icons.newspaper_rounded)),
              SliverToBoxAdapter(child: _buildNewsList(data.news)),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHero(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Container(
      height: 260,
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: Stack(
        children: [
          // Pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.landscape_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BLUD', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                          Text('Pariwisata Banyumas', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      const Spacer(),
                      if (auth.isLoggedIn)
                        CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(auth.user?.name.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const Spacer(),
                  const Text('Jelajahi Wisata\nBanyumas', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.2)),
                  const SizedBox(height: 8),
                  Text('Temukan destinasi wisata terbaik dan booking tempat dengan mudah',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.spacingLg, AppTheme.spacingLg, AppTheme.spacingLg, AppTheme.spacingSm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }

  Widget _buildWisataCarousel(List<ContentModel> contents) {
    if (contents.isEmpty) {
      return const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Belum ada data wisata')));
    }
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
        itemCount: contents.length,
        itemBuilder: (context, index) {
          final item = contents[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WisataDetailScreen(slug: item.slug))),
            child: Container(
              width: 170,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    item.imageUrl != null
                        ? CachedNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.cover, placeholder: (_, __) => Container(color: AppTheme.shimmerBase))
                        : Container(color: AppTheme.shimmerBase, child: const Icon(Icons.image, size: 40, color: AppTheme.textLight)),
                    Container(decoration: const BoxDecoration(gradient: AppTheme.heroGradient)),
                    Positioned(
                      bottom: 12, left: 12, right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                          if (item.location != null)
                            Row(children: [
                              const Icon(Icons.location_on, size: 12, color: Colors.white70),
                              const SizedBox(width: 4),
                              Expanded(child: Text(item.location!, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsList(List<NewsModel> news) {
    if (news.isEmpty) {
      return const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Belum ada berita')));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      itemCount: news.length > 5 ? 5 : news.length,
      itemBuilder: (context, index) {
        final item = news[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            onTap: () {
              if (item.source != null && item.source!.isNotEmpty) {
                launchUrl(Uri.parse(item.source!), mode: LaunchMode.externalApplication);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    child: SizedBox(
                      width: 80, height: 80,
                      child: item.imageUrl != null
                          ? CachedNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.cover)
                          : Container(color: AppTheme.shimmerBase, child: const Icon(Icons.newspaper, color: AppTheme.textLight)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        if (item.uploadTime != null)
                          Text(item.uploadTime!, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/data_provider.dart';
import 'wisata_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WisataListScreen extends StatefulWidget {
  const WisataListScreen({super.key});
  @override
  State<WisataListScreen> createState() => _WisataListScreenState();
}

class _WisataListScreenState extends State<WisataListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<DataProvider>(context, listen: false).fetchWisata());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Objek Wisata')),
      body: Consumer<DataProvider>(builder: (context, data, _) {
        if (data.isLoading && data.contents.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (data.contents.isEmpty) {
          return const Center(child: Text('Belum ada data wisata'));
        }
        return RefreshIndicator(
          onRefresh: () => data.fetchWisata(),
          child: GridView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 12, mainAxisSpacing: 12,
            ),
            itemCount: data.contents.length,
            itemBuilder: (context, index) {
              final item = data.contents[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WisataDetailScreen(slug: item.slug))),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    color: AppTheme.cardColor,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: item.imageUrl != null
                              ? CachedNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.cover, width: double.infinity)
                              : Container(color: AppTheme.shimmerBase, child: const Center(child: Icon(Icons.image, color: AppTheme.textLight))),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const Spacer(),
                                if (item.location != null)
                                  Row(children: [
                                    const Icon(Icons.location_on, size: 12, color: AppTheme.textLight),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(item.location!, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  ]),
                              ],
                            ),
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
      }),
    );
  }
}

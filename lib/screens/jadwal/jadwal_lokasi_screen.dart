import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/data_provider.dart';
import 'jadwal_bulan_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class JadwalLokasiScreen extends StatefulWidget {
  const JadwalLokasiScreen({super.key});
  @override
  State<JadwalLokasiScreen> createState() => _JadwalLokasiScreenState();
}

class _JadwalLokasiScreenState extends State<JadwalLokasiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<DataProvider>(context, listen: false).fetchWisata();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Booking')),
      body: Consumer<DataProvider>(builder: (context, data, _) {
        if (data.isLoading && data.contents.isEmpty) return const Center(child: CircularProgressIndicator());
        if (data.contents.isEmpty) return const Center(child: Text('Belum ada lokasi'));
        return RefreshIndicator(
          onRefresh: () => data.fetchWisata(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            itemCount: data.contents.length,
            itemBuilder: (context, index) {
              final item = data.contents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JadwalPerLokasiScreen(slug: item.slug, name: item.name))),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        child: SizedBox(
                          width: 64, height: 64,
                          child: item.imageUrl != null
                              ? CachedNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.cover)
                              : Container(color: AppTheme.shimmerBase, child: const Icon(Icons.landscape, color: AppTheme.textLight)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(item.location ?? '', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      )),
                      const Icon(Icons.chevron_right, color: AppTheme.textLight),
                    ]),
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

class JadwalPerLokasiScreen extends StatefulWidget {
  final String slug;
  final String name;
  const JadwalPerLokasiScreen({super.key, required this.slug, required this.name});
  @override
  State<JadwalPerLokasiScreen> createState() => _JadwalPerLokasiScreenState();
}

class _JadwalPerLokasiScreenState extends State<JadwalPerLokasiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<DataProvider>(context, listen: false).fetchJadwalByLocation(widget.slug);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Consumer<DataProvider>(builder: (context, data, _) {
        if (data.isLoading) return const Center(child: CircularProgressIndicator());
        if (data.jadwalBulan.isEmpty) return const Center(child: Text('Belum ada jadwal'));
        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: data.jadwalBulan.length,
          itemBuilder: (context, index) {
            final item = data.jadwalBulan[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
                ),
                title: Text(item.bulan, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${item.jumlahEvent} kegiatan'),
                trailing: const Icon(Icons.chevron_right, color: AppTheme.textLight),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JadwalBulanScreen(slug: widget.slug, bulan: item.bulan))),
              ),
            );
          },
        );
      }),
    );
  }
}

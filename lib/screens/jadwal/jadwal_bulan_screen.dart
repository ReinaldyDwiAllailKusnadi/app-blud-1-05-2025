import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/data_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class JadwalBulanScreen extends StatefulWidget {
  final String slug;
  final String bulan;
  const JadwalBulanScreen({super.key, required this.slug, required this.bulan});
  @override
  State<JadwalBulanScreen> createState() => _JadwalBulanScreenState();
}

class _JadwalBulanScreenState extends State<JadwalBulanScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<DataProvider>(context, listen: false).fetchJadwalByMonth(widget.slug, widget.bulan);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jadwal ${widget.bulan}')),
      body: Consumer<DataProvider>(builder: (context, data, _) {
        if (data.isLoading) return const Center(child: CircularProgressIndicator());
        if (data.monthEvents.isEmpty) return const Center(child: Text('Tidak ada kegiatan di bulan ini'));
        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: data.monthEvents.length,
          itemBuilder: (context, index) {
            final event = data.monthEvents[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: event.type == 'event' ? AppTheme.primaryColor.withValues(alpha: 0.1) : AppTheme.secondaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(
                          event.type == 'event' ? 'Event' : 'Booking',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: event.type == 'event' ? AppTheme.primaryColor : AppTheme.secondaryColor),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Text(event.nameEvent, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.date_range, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 6),
                      Text('${event.startDate} - ${event.endDate}', style: Theme.of(context).textTheme.bodySmall),
                    ]),
                    if (event.vendor != null) ...[
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.business, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(event.vendor!, style: Theme.of(context).textTheme.bodySmall),
                      ]),
                    ],
                    if (event.pdfUrl != null) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => launchUrl(Uri.parse(event.pdfUrl!), mode: LaunchMode.externalApplication),
                        icon: const Icon(Icons.picture_as_pdf, size: 16),
                        label: const Text('Lihat Rundown'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), textStyle: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

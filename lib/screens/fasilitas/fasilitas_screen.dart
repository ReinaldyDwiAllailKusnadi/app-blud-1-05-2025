import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/data_provider.dart';

class FasilitasScreen extends StatefulWidget {
  final String slug;
  const FasilitasScreen({super.key, required this.slug});
  @override
  State<FasilitasScreen> createState() => _FasilitasScreenState();
}

class _FasilitasScreenState extends State<FasilitasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<DataProvider>(context, listen: false).fetchFasilitas(widget.slug);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fasilitas & Harga Sewa')),
      body: Consumer<DataProvider>(builder: (context, data, _) {
        if (data.isLoading) return const Center(child: CircularProgressIndicator());
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.selectedContent != null)
                Text(data.selectedContent!.name, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 24),
              // Harga Sewa Table
              Text('Harga Sewa Tempat', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              if (data.prices.isEmpty)
                const Text('Belum ada data harga')
              else
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    child: Table(
                      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(2)},
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                          children: const [
                            Padding(padding: EdgeInsets.all(12), child: Text('Bagian', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                            Padding(padding: EdgeInsets.all(12), child: Text('Luas', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                            Padding(padding: EdgeInsets.all(12), child: Text('Harga', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                          ],
                        ),
                        ...data.prices.map((p) => TableRow(
                          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.dividerColor))),
                          children: [
                            Padding(padding: const EdgeInsets.all(12), child: Text(p.bagian ?? '-', style: const TextStyle(fontSize: 13))),
                            Padding(padding: const EdgeInsets.all(12), child: Text(p.luas ?? '-', style: const TextStyle(fontSize: 13))),
                            Padding(padding: const EdgeInsets.all(12), child: Text(p.price != null ? 'Rp ${p.price}' : '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.primaryColor))),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              // Fasilitas List
              Text('Fasilitas', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              if (data.facilities.isEmpty)
                const Text('Belum ada data fasilitas')
              else
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: data.facilities.map((f) => Chip(
                    avatar: const Icon(Icons.check_circle, size: 18, color: AppTheme.successColor),
                    label: Text(f.facilityName ?? '-'),
                  )).toList(),
                ),
              const SizedBox(height: 32),
              // CTA
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to booking form - will be handled by MainScreen nav
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text('BOOK NOW!'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

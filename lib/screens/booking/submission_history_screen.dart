import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/data_provider.dart';
import '../auth/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SubmissionHistoryScreen extends StatefulWidget {
  const SubmissionHistoryScreen({super.key});
  @override
  State<SubmissionHistoryScreen> createState() => _SubmissionHistoryScreenState();
}

class _SubmissionHistoryScreenState extends State<SubmissionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isLoggedIn) {
      Future.microtask(() => Provider.of<DataProvider>(context, listen: false).fetchHistory());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isLoggedIn) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.lock_outline, size: 64, color: AppTheme.textLight),
        const SizedBox(height: 16),
        const Text('Silakan login untuk melihat riwayat'),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), child: const Text('Login')),
      ]));
    }

    return Consumer<DataProvider>(builder: (context, data, _) {
      if (data.isLoading) return const Center(child: CircularProgressIndicator());
      if (data.submissions.isEmpty) {
        return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textLight),
          const SizedBox(height: 16),
          const Text('Belum ada pengajuan'),
        ]));
      }
      return RefreshIndicator(
        onRefresh: () => data.fetchHistory(),
        child: ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: data.submissions.length,
          itemBuilder: (context, index) {
            final item = data.submissions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(item.nameEvent, style: Theme.of(context).textTheme.titleMedium)),
                    _statusBadge(item.status),
                  ]),
                  const SizedBox(height: 10),
                  _infoRow(Icons.business, item.vendor),
                  _infoRow(Icons.location_on, item.location),
                  _infoRow(Icons.date_range, '${item.startDate} - ${item.endDate}'),
                  if (item.applyDate != null) _infoRow(Icons.access_time, 'Diajukan: ${item.applyDate}'),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.status == 'rejected' ? AppTheme.errorColor.withValues(alpha: 0.08) : AppTheme.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text('Catatan: ${item.notes}', style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                  // Document links
                  const SizedBox(height: 10),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    if (item.fileUrl != null) _docChip('Proposal', item.fileUrl!),
                    if (item.ktpUrl != null) _docChip('KTP', item.ktpUrl!),
                    if (item.applLetterUrl != null) _docChip('Surat Pengajuan', item.applLetterUrl!),
                    if (item.actvLetterUrl != null) _docChip('Surat Kegiatan', item.actvLetterUrl!),
                  ]),
                ]),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'approved': color = AppTheme.approvedColor; break;
      case 'rejected': color = AppTheme.rejectedColor; break;
      default: color = AppTheme.pendingColor;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
      ]),
    );
  }

  Widget _docChip(String label, String url) {
    return ActionChip(
      avatar: const Icon(Icons.picture_as_pdf, size: 14, color: AppTheme.primaryColor),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
    );
  }
}

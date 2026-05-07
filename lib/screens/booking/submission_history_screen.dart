import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/submission_provider.dart';
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
      Future.microtask(() {
        if (!mounted) return;
        Provider.of<SubmissionProvider>(context, listen: false).fetchHistory();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Riwayat Pengajuan'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _buildBody(auth),
    );
  }

  Widget _buildBody(AuthProvider auth) {
    if (!auth.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: AppTheme.textLight),
            const SizedBox(height: 16),
            const Text('Silakan login untuk melihat riwayat'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }

    return Consumer<SubmissionProvider>(builder: (context, data, _) {
      if (data.isLoading) return const Center(child: CircularProgressIndicator());
      if (data.history.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textLight),
              const SizedBox(height: 16),
              const Text('Belum ada pengajuan'),
              const SizedBox(height: 8),
              Text(
                'Akun: ${auth.user?.email ?? 'Tidak diketahui'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => data.fetchHistory(),
                child: const Text('Refresh'),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () => data.fetchHistory(),
        child: ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          itemCount: data.history.length,
          itemBuilder: (context, index) {
            final item = data.history[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.nameEvent,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _statusBadge(item.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _infoRow(Icons.business_rounded, item.vendor),
                    _infoRow(Icons.location_on_rounded, item.location),
                    _infoRow(Icons.calendar_month_rounded, '${item.startDate} - ${item.endDate}'),
                    if (item.applyDate != null) _infoRow(Icons.access_time_rounded, 'Diajukan: ${item.applyDate}'),
                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.status == 'rejected' ? Colors.red.shade50 : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Catatan Admin: ${item.notes}',
                          style: TextStyle(
                            fontSize: 13,
                            color: item.status == 'rejected' ? Colors.red.shade800 : Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                    // Document links
                    const SizedBox(height: 12),
                    const Divider(height: 24),
                    const Text(
                      'Dokumen Pendukung:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (item.fileUrl != null) _docChip('Proposal', item.fileUrl!),
                        if (item.ktpUrl != null) _docChip('KTP', item.ktpUrl!),
                        if (item.applLetterUrl != null) _docChip('Surat Pengajuan', item.applLetterUrl!),
                        if (item.actvLetterUrl != null) _docChip('Surat Kegiatan', item.actvLetterUrl!),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;
    
    switch (status.toLowerCase()) {
      case 'approved':
      case 'disetujui':
        color = const Color(0xFF16A34A); // Green
        label = 'Disetujui';
        break;
      case 'rejected':
      case 'ditolak':
        color = const Color(0xFFDC2626); // Red
        label = 'Ditolak';
        break;
      case 'pending':
      case 'menunggu':
      case 'waiting':
      default:
        color = const Color(0xFFEA580C); // Orange
        label = 'Menunggu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
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

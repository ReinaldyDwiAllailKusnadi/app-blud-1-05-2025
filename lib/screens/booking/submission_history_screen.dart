import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/submission_provider.dart';
import '../auth/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/widgets/app_layout.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/app_buttons.dart';

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
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          const AppGradientHeader(title: 'Riwayat Pengajuan'),
          Expanded(child: _buildBody(auth)),
        ],
      ),
    );
  }

  Widget _buildBody(AuthProvider auth) {
    if (!auth.isLoggedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_person_rounded, size: 80, color: AppTheme.textLight),
              const SizedBox(height: 24),
              const Text(
                'Akses Terbatas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan masuk ke akun Anda untuk melihat riwayat pengajuan sewa lokasi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              AppPrimaryButton(
                text: 'MASUK SEKARANG',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<SubmissionProvider>(builder: (context, data, _) {
      if (data.isLoading) return const AppLoading();
      
      if (data.history.isEmpty) {
        return const AppEmptyState(
          title: 'Belum Ada Pengajuan',
          subtitle: 'Anda belum pernah melakukan pengajuan sewa lokasi.',
        );
      }

      return RefreshIndicator(
        onRefresh: () => data.fetchHistory(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          itemCount: data.history.length,
          itemBuilder: (context, index) {
            final item = data.history[index];
            return AppCard(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.nameEvent,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, height: 1.2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AppStatusBadge(status: item.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoRow(Icons.business_rounded, item.vendor),
                  _infoRow(Icons.location_on_rounded, item.location),
                  _infoRow(Icons.calendar_month_rounded, '${item.startDate} - ${item.endDate}'),
                  if (item.applyDate != null) _infoRow(Icons.access_time_rounded, 'Diajukan: ${item.applyDate}'),
                  
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (item.status.toLowerCase() == 'rejected' || item.status.toLowerCase() == 'ditolak') 
                            ? AppTheme.errorColor.withValues(alpha: 0.1) 
                            : AppTheme.navBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Text(
                        'Catatan Admin: ${item.notes}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: (item.status.toLowerCase() == 'rejected' || item.status.toLowerCase() == 'ditolak') 
                              ? AppTheme.errorColor 
                              : AppTheme.navBlue,
                        ),
                      ),
                    ),
                  ],

                  const Divider(height: 32),
                  const Text(
                    'DOKUMEN TERLAMPIR:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textLight, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (item.fileUrl != null) _docButton('Proposal', item.fileUrl!),
                      if (item.ktpUrl != null) _docButton('KTP', item.ktpUrl!),
                      if (item.applLetterUrl != null) _docButton('Surat Pengajuan', item.applLetterUrl!),
                      if (item.actvLetterUrl != null) _docButton('Surat Kegiatan', item.actvLetterUrl!),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppTheme.textLight),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _docButton(String label, String url) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf_rounded, size: 14, color: AppTheme.errorColor),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}

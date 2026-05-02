import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../auth/welcome_screen.dart';
import '../../core/widgets/pressable.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Consumer<AuthProvider>(
        builder: (context, authProv, _) {
          final user = authProv.user;

          return Stack(
            children: [
              // ── Gradient Header Background ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 380,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1FACEB), Color(0xFF0F58D6), Color(0xFF2034A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // ── Scrollable Content ──
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      SizedBox(height: topPadding + 24),
                      _buildProfileHeader(user?.name ?? 'Guest', user?.username ?? '@guest'),
                      const SizedBox(height: 28),
                      _buildProfileCard(context, user, authProv),
                    ],
                  ),
                ),
              ),

            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String name, String username) {
    return Column(
      children: [
        Text(
          'Profil',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&h=300&fit=crop',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade100, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
              errorWidget: (context, url, error) => Container(color: Colors.white, child: const Icon(Icons.person, size: 50, color: Colors.grey)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          username.startsWith('@') ? username : '@$username',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFA5C5F6),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic user, AuthProvider authProv) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Profil',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          _ProfileItem(
            label: 'Nama',
            value: user?.name ?? '-',
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
          ),
          const SizedBox(height: 20),
          _ProfileItem(
            label: 'Username',
            value: user?.username ?? '-',
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
          ),

          const SizedBox(height: 28),
          Text(
            'Informasi Pribadi',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          _ProfileItem(
            label: 'ID Pengguna',
            value: user != null ? 'BLUD-${user.id}' : '-',
            trailing: const Icon(Icons.copy_rounded, color: Color(0xFF9CA3AF), size: 20),
          ),
          const SizedBox(height: 20),
          _ProfileItem(
            label: 'Email',
            value: user?.email ?? '-',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F5E9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Terverifikasi',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E8B57),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _ProfileItem(
            label: 'Nomor Telepon',
            value: user?.phone ?? '-',
          ),

          const SizedBox(height: 32),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _ActionPillButton(
                  label: 'Edit Profil',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit profil belum tersedia')),
                    );
                  },
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionPillButton(
                  label: 'Keluar',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Keluar'),
                        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true || !context.mounted) return;

                    await authProv.logout();

                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                        (route) => false,
                      );
                    }
                  },
                  isDanger: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _ProfileItem extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _ProfileItem({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _ActionPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isOutlined;
  final bool isDanger;

  const _ActionPillButton({
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = const Color(0xFF1461D2);
    Color textColor = Colors.white;
    Border? border;

    if (isOutlined) {
      bgColor = Colors.transparent;
      textColor = const Color(0xFF1461D2);
      border = Border.all(color: const Color(0xFF1461D2), width: 1);
    } else if (isDanger) {
      bgColor = const Color(0xFFFDEDED);
      textColor = const Color(0xFFD14F4F);
    }

    return Pressable(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: border,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}


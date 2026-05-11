import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/welcome_screen.dart';
import '../../core/widgets/pressable.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
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
                  child: SafeArea(
                    bottom: false,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          _buildProfileHeader(user?.name ?? 'Guest', user?.username ?? '@guest'),
                          const SizedBox(height: 28),
                          _buildProfileCard(context, user, authProv),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context, UserModel? user) {
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final usernameController = TextEditingController(text: user.username);
    final phoneController = TextEditingController(text: user.phone ?? '');
    final emailController = TextEditingController(text: user.email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Edit Profil',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 24),

              _buildFieldLabel('Nama Lengkap'),
              _buildTextField(nameController, 'Masukkan nama lengkap'),
              const SizedBox(height: 20),

              _buildFieldLabel('Username'),
              _buildTextField(usernameController, 'Masukkan username'),
              const SizedBox(height: 20),

              _buildFieldLabel('Nomor HP'),
              _buildTextField(
                phoneController, 
                'Masukkan nomor HP', 
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
              ),
              const SizedBox(height: 20),

              _buildFieldLabel('Email (Read-only)'),
              _buildTextField(emailController, '', enabled: false),
              const SizedBox(height: 32),

              Consumer<AuthProvider>(
                builder: (context, authProv, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: authProv.isLoading ? null : () async {
                        if (nameController.text.isEmpty || usernameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nama dan Username wajib diisi')),
                          );
                          return;
                        }

                        // Phone Validation (if provided)
                        final phone = phoneController.text.trim();
                        if (phone.isNotEmpty && (phone.length < 10 || phone.length > 12)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nomor HP minimal 10 digit dan maksimal 12 digit.')),
                          );
                          return;
                        }

                        final success = await authProv.updateProfile(
                          name: nameController.text.trim(),
                          username: usernameController.text.trim(),
                          phone: phoneController.text.trim(),
                          email: emailController.text.trim(),
                        );

                        if (context.mounted) {
                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profil berhasil diperbarui'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(authProv.errorMessage ?? 'Gagal memperbarui profil'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1461D2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: authProv.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Simpan Perubahan',
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool enabled = true, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: enabled ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
      ),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String username) {
    String initials = '';
    if (name.isNotEmpty) {
      final names = name.split(' ');
      if (names.length > 1) {
        initials = '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else {
        initials = names[0][0].toUpperCase();
      }
    } else {
      initials = '?';
    }

    return Column(
      children: [
        Text(
          'Profil Saya',
          style: GoogleFonts.inter(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 30),
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          username.startsWith('@') ? username : '@$username',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, UserModel? user, AuthProvider authProv) {
    final bool isWide = MediaQuery.of(context).size.width > 600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Profil',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _profileInfoItem(context, 'Nama Lengkap', user?.name ?? '-', isWide),
              _profileInfoItem(context, 'Username', user?.username ?? '-', isWide),
              _profileInfoItem(context, 'Email', user?.email ?? '-', isWide),
              _profileInfoItem(context, 'Nomor HP', user?.phone ?? '-', isWide),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: _ActionPillButton(
                  label: 'Edit Profil',
                  onPressed: () => _showEditBottomSheet(context, user),
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ActionPillButton(
                  label: 'Keluar Akun',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        title: Text(
                          'Keluar Akun?',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        content: Text(
                          'Apakah Anda yakin ingin keluar dari akun ini?',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: 15,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              'Batal',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF1C7EE8),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'Keluar',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFEF4444),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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

  Widget _profileInfoItem(BuildContext context, String label, String value, bool isWide) {
    return SizedBox(
      width: isWide ? (MediaQuery.of(context).size.width - 120) / 2 : double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.isNotEmpty ? value : '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
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


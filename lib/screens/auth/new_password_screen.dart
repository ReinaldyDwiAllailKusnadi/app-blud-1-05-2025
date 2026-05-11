import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'shared_auth_widgets.dart';
import '../../providers/auth_provider.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const NewPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword() async {
    final password = _passCtrl.text;
    final confirmPassword = _confirmPassCtrl.text;

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru wajib diisi.')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 8 karakter.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak sesuai.')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(
      email: widget.email,
      code: widget.code,
      password: password,
      passwordConfirmation: confirmPassword,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diubah. Silakan login kembali.')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } else if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.bgContainer,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.only(left: 14, top: 10),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const LogoBlud(),
                    const SizedBox(height: 42),

                    Text(
                      'Buat Password Baru',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AuthColors.textPrimary,
                        height: 1.1,
                        letterSpacing: -0.03 * 30,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Masukkan password baru untuk akun Anda.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AuthColors.textSubtitle,
                        height: 1.4,
                        letterSpacing: -0.01 * 15,
                      ),
                    ),

                    const SizedBox(height: 50),

                    _AuthTextField(
                      controller: _passCtrl,
                      hintText: 'Password Baru',
                      prefixIcon: Icons.lock_rounded,
                      obscureText: _obscurePass,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscurePass = !_obscurePass),
                        child: Icon(
                          _obscurePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          size: 22,
                          color: AuthColors.inputIcon,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _AuthTextField(
                      controller: _confirmPassCtrl,
                      hintText: 'Konfirmasi Password Baru',
                      prefixIcon: Icons.lock_clock_rounded,
                      obscureText: _obscureConfirm,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        child: Icon(
                          _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          size: 22,
                          color: AuthColors.inputIcon,
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),

                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return GradientButton(
                          label: auth.isLoading ? 'Memproses...' : 'Ubah Password',
                          onTap: auth.isLoading ? () {} : _handleUpdatePassword,
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    AuthHoverLink(
                      text: 'Kembali ke Login',
                      onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;

  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Icon(prefixIcon, size: 22, color: AuthColors.inputIcon),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: GoogleFonts.inter(
                fontSize: 15.5,
                fontWeight: FontWeight.w400,
                color: AuthColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.inter(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (suffixIcon != null) ...[
            suffixIcon!,
            const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }
}

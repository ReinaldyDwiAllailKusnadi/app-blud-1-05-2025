import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'shared_auth_widgets.dart';
import '../../providers/auth_provider.dart';
import '../main/main_screen.dart';

/// Register Screen - BLUD Pariwisata
/// Full screen native Flutter, tanpa phone frame/mockup.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _passConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    final confirm = _passConfirmCtrl.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama, Email, dan Password wajib diisi.')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok.')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register({
      'name': name,
      'phone': phone.isEmpty ? null : phone,
      'email': email,
      'password': password,
      'password_confirmation': confirm,
    });

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
        (route) => false,
      );
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
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
              // ── Back Button ──
              Padding(
                padding: const EdgeInsets.only(left: 14, top: 10),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),

              // ── Main Content ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Title ──
                    Text(
                      'Daftar Akun',
                      style: GoogleFonts.inter(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A101D),
                        height: 1.1,
                        letterSpacing: -0.03 * 34,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Subtitle ──
                    Text(
                      'Isi data diri Anda untuk membuat akun.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Form Inputs ──
                    _RegisterTextField(
                      controller: _nameCtrl,
                      hintText: 'Nama Lengkap',
                      keyboardType: TextInputType.name,
                    ),

                    const SizedBox(height: 18),

                    _RegisterTextField(
                      controller: _phoneCtrl,
                      hintText: 'Nomor WhatsApp',
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 18),

                    _RegisterTextField(
                      controller: _emailCtrl,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 18),

                    _RegisterTextField(
                      controller: _passCtrl,
                      hintText: 'Kata Sandi',
                      obscureText: true,
                    ),

                    const SizedBox(height: 18),

                    _RegisterTextField(
                      controller: _passConfirmCtrl,
                      hintText: 'Konfirmasi Kata Sandi',
                      obscureText: true,
                    ),

                    const SizedBox(height: 24),

                    // ── Info Box ──
                    const _InfoBox(),

                    const SizedBox(height: 32),

                    // ── Daftar Button (Gradient) ──
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return GradientButton(
                          label: auth.isLoading ? 'Mendaftarkan...' : 'Daftar',
                          onTap: auth.isLoading ? () {} : _handleRegister,
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // ── Footer ──
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah punya akun? ',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Login di sini',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ],
                      ),
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

// ═══════════════════════════════════════════════════════════
// Register Text Field (rounded pill, no prefix icon)
// ═══════════════════════════════════════════════════════════
class _RegisterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;

  const _RegisterTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF334155),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Info Box (Yellow warning/info)
// ═══════════════════════════════════════════════════════════
class _InfoBox extends StatelessWidget {
  const _InfoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7D6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFBE39D), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: Color(0xFFC99120),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Kami akan mengirimkan kode verifikasi ke nomor WhatsApp Anda.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1E293B),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

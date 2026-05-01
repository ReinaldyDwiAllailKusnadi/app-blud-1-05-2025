import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'register_screen.dart';
import 'shared_auth_widgets.dart';
import '../../providers/auth_provider.dart';
import '../main/main_screen.dart';

/// Login Screen - BLUD Pariwisata
/// Full screen native Flutter, tanpa phone frame/mockup.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi.')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(email, password);

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
                      size: 20,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),

              // ── Main Content ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ── Logo ──
                    const LogoBlud(),

                    const SizedBox(height: 42),

                    // ── Title ──
                    Text(
                      'Login ke Akun Anda',
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

                    // ── Subtitle ──
                    Text(
                      'Temukan keindahan wisata dan\nbudaya lokal bersama kami.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AuthColors.textSubtitle,
                        height: 1.4,
                        letterSpacing: -0.01 * 15,
                      ),
                    ),

                    const SizedBox(height: 74),

                    // ── Email Input ──
                    _AuthTextField(
                      controller: _emailCtrl,
                      hintText: 'Email',
                      prefixIcon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 20),

                    // ── Password Input ──
                    _AuthTextField(
                      controller: _passCtrl,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_rounded,
                      obscureText: _obscure,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                          _obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 22,
                          color: AuthColors.inputIcon,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Remember Me + Forgot Password Row ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Checkbox + Label
                        GestureDetector(
                          onTap: () => setState(() => _rememberMe = !_rememberMe),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: 1.5,
                                  ),
                                  activeColor: AuthColors.bluePrimary,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ingat saya',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AuthColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Forgot Password
                        GestureDetector(
                          onTap: () {
                            // TODO: Navigate to forgot password
                          },
                          child: Text(
                            'Lupa password?',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AuthColors.signUpBlue,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 34),

                    // ── Login Button (Gradient) ──
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return GradientButton(
                          label: auth.isLoading ? 'Loading...' : 'Login',
                          onTap: auth.isLoading ? () {} : _handleLogin,
                        );
                      },
                    ),

                    const SizedBox(height: 46),

                    // ── Footer ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: AuthColors.footerGray,
                            letterSpacing: -0.02 * 14.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Daftar di sini',
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AuthColors.signUpBlue,
                              letterSpacing: -0.02 * 14.5,
                            ),
                          ),
                        ),
                      ],
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
// Auth Text Field (Reusable rounded pill input)
// ═══════════════════════════════════════════════════════════
class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
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
          Icon(
            prefixIcon,
            size: 22,
            color: AuthColors.inputIcon,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
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
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
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

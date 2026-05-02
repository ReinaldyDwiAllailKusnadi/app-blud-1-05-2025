import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'shared_auth_widgets.dart';
import '../../providers/auth_provider.dart';
import '../main/main_screen.dart';

/// Welcome Screen - BLUD Pariwisata
/// Full screen native Flutter, tanpa phone frame/mockup.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.loginWithGoogle();

    if (success && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
        (route) => false,
      );
    } else if (context.mounted && authProvider.errorMessage != null) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 76),

                // ── Logo ──
                const LogoBlud(),

                const SizedBox(height: 44),

                // ── Title ──
                Text(
                  'Selamat Datang\ndi Banyumas',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AuthColors.textPrimary,
                    height: 1.08,
                    letterSpacing: -0.03 * 34,
                  ),
                ),

                const SizedBox(height: 14),

                // ── Subtitle ──
                Text(
                  'Temukan keindahan wisata dan\nbudaya lokal bersama kami.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    color: AuthColors.textSubtitle,
                    height: 1.4,
                    letterSpacing: -0.02 * 15.5,
                  ),
                ),

                const SizedBox(height: 64),

                // ── Gradient Login Button ──
                GradientButton(
                  label: 'Login with Email & Password',
                  icon: const Icon(Icons.email_rounded, color: Colors.white, size: 20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // ── Google Button ──
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return Pressable(
                      onTap: auth.isLoading ? null : () => _handleGoogleSignIn(context),
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AuthColors.googleBorder, width: 1),
                        ),
                        child: auth.isLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(20, 20),
                                    painter: GoogleLogoPainter(),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Sign in with Google',
                                    style: GoogleFonts.inter(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      color: AuthColors.googleText,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 34),

                // ── Footer ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: AuthColors.footerGray,
                        letterSpacing: -0.02 * 14.5,
                      ),
                    ),
                    AuthHoverLink(
                      text: 'Sign up',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

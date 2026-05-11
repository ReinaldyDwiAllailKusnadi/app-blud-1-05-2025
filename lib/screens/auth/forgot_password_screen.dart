import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'shared_auth_widgets.dart';
import 'verify_reset_code_screen.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email wajib diisi.')),
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format email tidak valid.')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final message = await authProvider.forgotPassword(email);

    if (mounted) {
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyResetCodeScreen(email: email),
          ),
        );
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
                      'Lupa Password?',
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
                      'Masukkan email akun Anda untuk menerima kode reset password.',
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
                      controller: _emailCtrl,
                      hintText: 'Email',
                      prefixIcon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 34),

                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return GradientButton(
                          label: auth.isLoading ? 'Mengirim...' : 'Kirim Kode',
                          onTap: auth.isLoading ? () {} : _handleForgotPassword,
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ingat password? ',
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: AuthColors.footerGray,
                          ),
                        ),
                        AuthHoverLink(
                          text: 'Login di sini',
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
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
  final TextInputType keyboardType;

  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
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
          Icon(prefixIcon, size: 22, color: AuthColors.inputIcon),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
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
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

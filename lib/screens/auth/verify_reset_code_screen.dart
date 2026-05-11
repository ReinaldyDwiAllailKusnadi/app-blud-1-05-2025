import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'shared_auth_widgets.dart';
import 'new_password_screen.dart';
import '../../providers/auth_provider.dart';

class VerifyResetCodeScreen extends StatefulWidget {
  final String email;

  const VerifyResetCodeScreen({super.key, required this.email});

  @override
  State<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyCode() async {
    final code = _codeCtrl.text.trim();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode reset harus 6 digit.')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyResetCode(
      email: widget.email,
      code: code,
    );

    if (mounted) {
      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewPasswordScreen(
              email: widget.email,
              code: code,
            ),
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
                      'Verifikasi Kode',
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
                      'Masukkan kode 6 digit yang dikirim ke email Anda.',
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
                      controller: _codeCtrl,
                      hintText: 'Kode Reset (6 digit)',
                      prefixIcon: Icons.pin_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                    ),

                    const SizedBox(height: 34),

                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return GradientButton(
                          label: auth.isLoading ? 'Memverifikasi...' : 'Verifikasi Kode',
                          onTap: auth.isLoading ? () {} : _handleVerifyCode,
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    AuthHoverLink(
                      text: 'Kembali ke Login',
                      onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
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
  final List<TextInputFormatter>? inputFormatters;

  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
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
              inputFormatters: inputFormatters,
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

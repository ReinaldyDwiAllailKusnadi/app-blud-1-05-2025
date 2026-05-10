import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class MainTabHeader extends StatelessWidget {
  final String title;

  const MainTabHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    
    return Container(
      width: double.infinity,
      height: topPadding + 64,
      decoration: const BoxDecoration(
        gradient: AppTheme.blueHeaderGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'pressable.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double? width;
  final double height;
  final bool isLoading;
  final IconData? icon;

  const AppPrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.width,
    this.height = 54,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: AppTheme.blueHeaderGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppTheme.navBlue.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double? width;
  final double height;
  final IconData? icon;
  final bool isDanger;

  const AppSecondaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.width,
    this.height = 54,
    this.icon,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: isDanger ? const Color(0xFFFEF2F2) : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: isDanger ? AppTheme.errorColor : AppTheme.navBlue, 
            width: 1.5
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon, 
                  color: isDanger ? AppTheme.errorColor : AppTheme.navBlue, 
                  size: 20
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text.toUpperCase(),
                style: GoogleFonts.inter(
                  color: isDanger ? AppTheme.errorColor : AppTheme.navBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

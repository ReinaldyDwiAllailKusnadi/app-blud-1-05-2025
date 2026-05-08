import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// UI Design System - Updated: 2026-05-07 20:02 (Force Rebuild)
class AppGradientHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final double? height;
  final Widget? child;

  const AppGradientHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final calculatedHeight = height ?? (child != null ? 200.0 : topPadding + 64.0);

    return Container(
      height: calculatedHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppTheme.blueHeaderGradient,
      ),
      child: Stack(
        children: [
          // Background/Child Area
          if (child != null)
            Positioned.fill(
              top: topPadding + 64,
              child: child!,
            ),
          
          // Header Content Area
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: 64,
              child: Stack(
                children: [
                  // Leading (Back Button)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: leading ?? (Navigator.canPop(context) ? IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 32),
                      ) : null),
                    ),
                  ),
                  
                  // Title
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 56),
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
                  
                  // Actions
                  if (actions != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions!,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? color;
  final bool hasShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color ?? AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusXl),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: hasShadow ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ] : [],
      ),
      child: child,
    );
  }
}

class AppSectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const AppSectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionLabel!,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.navBlue,
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════
// Design Tokens - Shared across all auth screens
// ═══════════════════════════════════════════════════════════
class AuthColors {
  static const Color bgContainer = Color(0xFFFCFCFD);
  static const Color textPrimary = Color(0xFF101726);
  static const Color textSubtitle = Color(0xFF4B5563);
  static const Color bluePrimary = Color(0xFF3A83F5);
  static const Color blueGradientStart = Color(0xFF5CA3FF);
  static const Color blueGradientEnd = Color(0xFF3A83F5);
  static const Color googleBorder = Color(0xFFCBCFD6);
  static const Color googleText = Color(0xFF636C7C);
  static const Color footerGray = Color(0xFF768091);
  static const Color signUpBlue = Color(0xFF3A82F5);
  static const Color logoBlue = Color(0xFF1489EE);
  static const Color inputIcon = Color(0xFF6B7280);
}

// ═══════════════════════════════════════════════════════════
// BLUD Logo Widget
// ═══════════════════════════════════════════════════════════
class LogoBlud extends StatelessWidget {
  const LogoBlud({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.translate(
          offset: const Offset(-6, 0),
          child: CustomPaint(
            size: const Size(86, 86),
            painter: BludLogoPainter(),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BLUD',
              style: GoogleFonts.inter(
                fontSize: 35,
                fontWeight: FontWeight.w900,
                color: AuthColors.logoBlue,
                height: 0.8,
                letterSpacing: -0.01 * 35,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'PARIWISATA',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AuthColors.logoBlue,
                letterSpacing: 0.06 * 13.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Gradient Button (Reusable)
// ═══════════════════════════════════════════════════════════
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Widget? icon;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AuthColors.blueGradientStart, AuthColors.blueGradientEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AuthColors.bluePrimary.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 10)],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Custom Painters
// ═══════════════════════════════════════════════════════════

/// BLUD Logo icon (colorful pinwheel/flower)
class BludLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = size.width / 100;

    canvas.save();
    canvas.translate(cx, cy);

    void drawLeaf(double angle, Color color, {double y = -40, double h = 30}) {
      canvas.save();
      canvas.rotate(angle * 3.14159 / 180);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(-9.5 * scale, y * scale, 19 * scale, h * scale),
        Radius.circular(9.5 * scale),
      );
      canvas.drawRRect(rect, Paint()..color = color);
      canvas.restore();
    }

    drawLeaf(-38, const Color(0xFF21A752));
    drawLeaf(38, const Color(0xFF68C73B));
    drawLeaf(110, const Color(0xFF2AB5FA), y: -38);
    drawLeaf(-110, const Color(0xFF1679F1), y: -38);

    canvas.save();
    canvas.rotate(18 * 3.14159 / 180);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-18 * scale, 8 * scale, 15 * scale, 24 * scale),
        Radius.circular(7.5 * scale),
      ),
      Paint()..color = const Color(0xFFF83965),
    );
    canvas.restore();

    canvas.save();
    canvas.rotate(-18 * 3.14159 / 180);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3 * scale, 8 * scale, 15 * scale, 24 * scale),
        Radius.circular(7.5 * scale),
      ),
      Paint()..color = const Color(0xFFF83965),
    );
    canvas.restore();

    canvas.drawCircle(
      Offset.zero,
      14 * scale,
      Paint()..color = const Color(0xFFF83965),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Google "G" logo
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;

    final bluePath = Path()
      ..moveTo(22.56 * s, 12.25 * s)
      ..cubicTo(22.56 * s, 11.47 * s, 22.49 * s, 10.72 * s, 22.36 * s, 10 * s)
      ..lineTo(12 * s, 10 * s)
      ..lineTo(12 * s, 14.26 * s)
      ..lineTo(17.92 * s, 14.26 * s)
      ..cubicTo(17.66 * s, 15.63 * s, 16.88 * s, 16.79 * s, 15.71 * s, 17.57 * s)
      ..lineTo(15.71 * s, 20.34 * s)
      ..lineTo(19.28 * s, 20.34 * s)
      ..cubicTo(21.36 * s, 18.42 * s, 22.56 * s, 15.6 * s, 22.56 * s, 12.25 * s)
      ..close();
    canvas.drawPath(bluePath, Paint()..color = const Color(0xFF4285F4));

    final greenPath = Path()
      ..moveTo(12 * s, 23 * s)
      ..cubicTo(14.97 * s, 23 * s, 17.46 * s, 22.02 * s, 19.28 * s, 20.34 * s)
      ..lineTo(15.71 * s, 17.57 * s)
      ..cubicTo(14.73 * s, 18.23 * s, 13.48 * s, 18.63 * s, 12 * s, 18.63 * s)
      ..cubicTo(9.14 * s, 18.63 * s, 6.71 * s, 16.7 * s, 5.84 * s, 14.1 * s)
      ..lineTo(2.18 * s, 16.94 * s)
      ..cubicTo(3.99 * s, 20.53 * s, 7.7 * s, 23 * s, 12 * s, 23 * s)
      ..close();
    canvas.drawPath(greenPath, Paint()..color = const Color(0xFF34A853));

    final yellowPath = Path()
      ..moveTo(5.84 * s, 14.09 * s)
      ..cubicTo(5.62 * s, 13.43 * s, 5.49 * s, 12.73 * s, 5.49 * s, 12 * s)
      ..cubicTo(5.49 * s, 11.27 * s, 5.62 * s, 10.57 * s, 5.84 * s, 9.91 * s)
      ..lineTo(5.84 * s, 7.07 * s)
      ..lineTo(2.18 * s, 7.07 * s)
      ..cubicTo(1.43 * s, 8.55 * s, 1 * s, 10.22 * s, 1 * s, 12 * s)
      ..cubicTo(1 * s, 13.78 * s, 1.43 * s, 15.45 * s, 2.18 * s, 16.93 * s)
      ..lineTo(5.84 * s, 14.09 * s)
      ..close();
    canvas.drawPath(yellowPath, Paint()..color = const Color(0xFFFBBC05));

    final redPath = Path()
      ..moveTo(12 * s, 5.38 * s)
      ..cubicTo(13.62 * s, 5.38 * s, 15.06 * s, 5.94 * s, 16.21 * s, 7.02 * s)
      ..lineTo(19.36 * s, 3.87 * s)
      ..cubicTo(17.45 * s, 2.09 * s, 14.97 * s, 1 * s, 12 * s, 1 * s)
      ..cubicTo(7.7 * s, 1 * s, 3.99 * s, 3.47 * s, 2.18 * s, 7.07 * s)
      ..lineTo(5.84 * s, 9.91 * s)
      ..cubicTo(6.71 * s, 7.31 * s, 9.14 * s, 5.38 * s, 12 * s, 5.38 * s)
      ..close();
    canvas.drawPath(redPath, Paint()..color = const Color(0xFFEA4335));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

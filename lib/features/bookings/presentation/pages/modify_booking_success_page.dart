import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ModifyBookingSuccessPage extends StatelessWidget {
  const ModifyBookingSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // No AppBar — full immersive success screen
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),

                    // Title
                    const Text(
                      'Booking Updated',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Body text
                    const Text(
                      'Your changes have been sent to the professional. You can track the status in the "My Bookings" section.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Illustration
                    Center(child: _SuccessIllustration()),
                    const SizedBox(height: 40),

                    const Center(
                      child: Text(
                        'We appreciate your trust in\nour service.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Done button
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Pop all the way back to My Bookings
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Illustration ─────────────────────────────────────────────────────────────

class _SuccessIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 230,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Document / booking card
          Positioned(
            left: 16,
            bottom: 8,
            child: Container(
              width: 160,
              height: 165,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fake header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Color(0xFFF0F0F0), width: 1)),
                    ),
                    child: Row(
                      children: [
                        const Text('• • •',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 9,
                                letterSpacing: 2)),
                        const SizedBox(width: 8),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Checkmark circle
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryOrange.withOpacity(0.12),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.primaryOrange,
                          size: 30,
                        ),
                      ),
                    ),
                  ),

                  // Fake text lines
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 7,
                          width: 90,
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 7,
                          width: 130,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Professional figure (custom painter)
          Positioned(
            right: 8,
            bottom: 8,
            child: SizedBox(
              width: 120,
              height: 210,
              child: CustomPaint(painter: _ProfessionalPainter()),
            ),
          ),

          // Clock badge top-right
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border:
                    Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.edit_outlined,
                  color: AppColors.primaryDark, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalPainter extends CustomPainter {
  static const Color _dark = AppColors.primaryDark;
  static const Color _orange = AppColors.primaryOrange;
  static const Color _skin = Color(0xFFE8B89A);

  @override
  void paint(Canvas canvas, Size size) {
    final dark = Paint()..color = _dark;
    final orange = Paint()..color = _orange;
    final skin = Paint()..color = _skin;

    // Legs
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.30, size.height * 0.65,
                size.width * 0.18, size.height * 0.32),
            const Radius.circular(8)),
        dark);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.52, size.height * 0.63,
                size.width * 0.18, size.height * 0.30),
            const Radius.circular(8)),
        dark);
    // Feet
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.26, size.height * 0.93,
                size.width * 0.22, size.height * 0.06),
            const Radius.circular(5)),
        dark);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.50, size.height * 0.91,
                size.width * 0.22, size.height * 0.06),
            const Radius.circular(5)),
        dark);
    // Torso
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.20, size.height * 0.36,
                size.width * 0.58, size.height * 0.32),
            const Radius.circular(14)),
        orange);
    // Left arm
    final leftArm = Path()
      ..moveTo(size.width * 0.20, size.height * 0.40)
      ..quadraticBezierTo(size.width * 0.00, size.height * 0.50,
          size.width * 0.06, size.height * 0.62)
      ..lineTo(size.width * 0.16, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.12, size.height * 0.50,
          size.width * 0.28, size.height * 0.42)
      ..close();
    canvas.drawPath(leftArm, orange);
    canvas.drawCircle(
        Offset(size.width * 0.08, size.height * 0.63),
        size.width * 0.06,
        skin);
    // Right arm
    final rightArm = Path()
      ..moveTo(size.width * 0.78, size.height * 0.40)
      ..quadraticBezierTo(size.width * 0.88, size.height * 0.52,
          size.width * 0.80, size.height * 0.62)
      ..lineTo(size.width * 0.70, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.76, size.height * 0.50,
          size.width * 0.68, size.height * 0.42)
      ..close();
    canvas.drawPath(rightArm, orange);
    // Neck
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * 0.42, size.height * 0.28,
                size.width * 0.16, size.height * 0.10),
            const Radius.circular(4)),
        skin);
    // Head
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.50, size.height * 0.20),
            width: size.width * 0.34,
            height: size.width * 0.36),
        skin);
    // Hair
    final hair = Paint()..color = _dark;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.50, size.height * 0.06),
            width: size.width * 0.22,
            height: size.width * 0.18),
        hair);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.34, size.height * 0.14),
            width: size.width * 0.14,
            height: size.width * 0.20),
        hair);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.66, size.height * 0.14),
            width: size.width * 0.14,
            height: size.width * 0.20),
        hair);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

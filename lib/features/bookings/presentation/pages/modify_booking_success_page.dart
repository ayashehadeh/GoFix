import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ModifyBookingSuccessPage extends StatefulWidget {
  const ModifyBookingSuccessPage({super.key});

  @override
  State<ModifyBookingSuccessPage> createState() =>
      _ModifyBookingSuccessPageState();
}

class _ModifyBookingSuccessPageState extends State<ModifyBookingSuccessPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSuccessSheet());
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      // Not dismissible — user must tap Done
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _SuccessSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Background: the Modification 3 review screen (booking details),
    // which is already underneath on the navigator stack. This page
    // is intentionally minimal — the sheet is the main content.
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Modify Booking',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
    );
  }
}

// ─── Success bottom sheet ─────────────────────────────────────────────────────

class _SuccessSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Blurred + dimmed backdrop ──────────────────────────────────────
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.black.withOpacity(0.25)),
        ),

        // ── Sheet ──────────────────────────────────────────────────────────
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 48),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle (decorative — sheet is not dismissible)
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 28),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const Text(
                  'Booking Updated',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),

                const Text(
                  'Your changes have been sent to the professional. '
                  'You can track the status in the "My Bookings" section.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 32),

                // Illustration
                Center(child: _SuccessIllustration()),
                const SizedBox(height: 32),

                const Center(
                  child: Text(
                    'We appreciate your trust in\nour service.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Done button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close sheet
                      // Pop all the way back to My Bookings
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Compact illustration ─────────────────────────────────────────────────────

class _SuccessIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 170,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Document card
          Positioned(
            left: 10,
            bottom: 6,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
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
                  // Fake header bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 7,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '• • •',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 8,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Check circle
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryOrange.withOpacity(0.12),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.primaryOrange,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  // Fake text lines
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                    child: Column(
                      children: [
                        Container(
                          height: 6,
                          width: 70,
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 6,
                          width: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Professional figure
          Positioned(
            right: 6,
            bottom: 6,
            child: SizedBox(
              width: 90,
              height: 160,
              child: CustomPaint(painter: _ProfPainter()),
            ),
          ),

          // Edit badge top-right
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.primaryDark,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfPainter extends CustomPainter {
  static const _dark = AppColors.primaryDark;
  static const _orange = AppColors.primaryOrange;
  static const _skin = Color(0xFFE8B89A);

  @override
  void paint(Canvas canvas, Size s) {
    final dark = Paint()..color = _dark;
    final orange = Paint()..color = _orange;
    final skin = Paint()..color = _skin;

    // Legs
    for (final x in [0.30, 0.52]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            s.width * x,
            s.height * 0.65,
            s.width * 0.18,
            s.height * 0.32,
          ),
          const Radius.circular(8),
        ),
        dark,
      );
    }
    // Feet
    for (final pair in [
      [0.26, 0.93],
      [0.50, 0.91],
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            s.width * pair[0],
            s.height * pair[1],
            s.width * 0.22,
            s.height * 0.06,
          ),
          const Radius.circular(5),
        ),
        dark,
      );
    }
    // Torso
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.20,
          s.height * 0.36,
          s.width * 0.58,
          s.height * 0.32,
        ),
        const Radius.circular(14),
      ),
      orange,
    );
    // Arms
    final leftArm = Path()
      ..moveTo(s.width * 0.20, s.height * 0.40)
      ..quadraticBezierTo(
        s.width * 0.00,
        s.height * 0.50,
        s.width * 0.06,
        s.height * 0.62,
      )
      ..lineTo(s.width * 0.16, s.height * 0.58)
      ..quadraticBezierTo(
        s.width * 0.12,
        s.height * 0.50,
        s.width * 0.28,
        s.height * 0.42,
      )
      ..close();
    canvas.drawPath(leftArm, orange);
    canvas.drawCircle(
      Offset(s.width * 0.08, s.height * 0.63),
      s.width * 0.06,
      skin,
    );
    final rightArm = Path()
      ..moveTo(s.width * 0.78, s.height * 0.40)
      ..quadraticBezierTo(
        s.width * 0.88,
        s.height * 0.52,
        s.width * 0.80,
        s.height * 0.62,
      )
      ..lineTo(s.width * 0.70, s.height * 0.58)
      ..quadraticBezierTo(
        s.width * 0.76,
        s.height * 0.50,
        s.width * 0.68,
        s.height * 0.42,
      )
      ..close();
    canvas.drawPath(rightArm, orange);
    // Neck
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.42,
          s.height * 0.28,
          s.width * 0.16,
          s.height * 0.10,
        ),
        const Radius.circular(4),
      ),
      skin,
    );
    // Head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s.width * 0.50, s.height * 0.20),
        width: s.width * 0.34,
        height: s.width * 0.36,
      ),
      skin,
    );
    // Hair
    final hair = Paint()..color = _dark;
    for (final c in [
      [0.50, 0.06, 0.22, 0.18],
      [0.34, 0.14, 0.14, 0.20],
      [0.66, 0.14, 0.14, 0.20],
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(s.width * c[0], s.height * c[1]),
          width: s.width * c[2],
          height: s.width * c[3],
        ),
        hair,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

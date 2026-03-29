import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/home/presentation/bloc/home_bloc.dart';
import 'package:gp/features/home/presentation/pages/home_page.dart';
import 'package:gp/injection_container.dart' as di;

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  static const Color darkBlue = Color(0xFF1A2B4A);
  static const Color orange = Color(0xFFFF8C00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    const Text(
                      "We've Got It From Here!",
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your request is now pending. Please allow some time for the professional to review the details. You can track the status of this request in the "My Bookings" section.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(child: _buildIllustration()),
                    const SizedBox(height: 40),
                    const Center(
                      child: Text(
                        'We appreciate your trust in\nour service.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Done Button
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => di.sl<HomeBloc>(),
                          child: const HomePage(),
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      width: 320,
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 20,
            bottom: 10,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('• • •',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                letterSpacing: 2)),
                        const SizedBox(width: 8),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: darkBlue.withOpacity(0.15), width: 1.5),
                        ),
                        child: const Icon(Icons.settings_outlined,
                            color: darkBlue, size: 30),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 7,
                          width: 100,
                          decoration: BoxDecoration(
                            color: orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 7,
                          width: 140,
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
          Positioned(
            right: 10,
            bottom: 10,
            child: SizedBox(
              width: 130,
              height: 230,
              child: CustomPaint(painter: _PersonPainter()),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.timer_outlined, color: darkBlue, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonPainter extends CustomPainter {
  static const Color darkBlue = Color(0xFF1A2B4A);
  static const Color orange = Color(0xFFFF8C00);
  static const Color skin = Color(0xFFE8B89A);

  @override
  void paint(Canvas canvas, Size size) {
    final paintDarkBlue = Paint()..color = darkBlue;
    final paintOrange = Paint()..color = orange;
    final paintSkin = Paint()..color = skin;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.32, size.height * 0.65, size.width * 0.18,
            size.height * 0.32),
        const Radius.circular(8),
      ),
      paintDarkBlue,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.52, size.height * 0.63, size.width * 0.18,
            size.height * 0.30),
        const Radius.circular(8),
      ),
      paintDarkBlue,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.28, size.height * 0.92, size.width * 0.22,
            size.height * 0.06),
        const Radius.circular(5),
      ),
      paintDarkBlue,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.50, size.height * 0.90, size.width * 0.22,
            size.height * 0.06),
        const Radius.circular(5),
      ),
      paintDarkBlue,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.22, size.height * 0.36, size.width * 0.56,
            size.height * 0.32),
        const Radius.circular(14),
      ),
      paintOrange,
    );

    final leftArm = Path()
      ..moveTo(size.width * 0.22, size.height * 0.40)
      ..quadraticBezierTo(size.width * 0.02, size.height * 0.50,
          size.width * 0.08, size.height * 0.62)
      ..lineTo(size.width * 0.18, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.14, size.height * 0.50,
          size.width * 0.30, size.height * 0.42)
      ..close();
    canvas.drawPath(leftArm, paintOrange);
    canvas.drawCircle(Offset(size.width * 0.10, size.height * 0.63),
        size.width * 0.06, paintSkin);

    final rightArm = Path()
      ..moveTo(size.width * 0.78, size.height * 0.40)
      ..quadraticBezierTo(size.width * 0.88, size.height * 0.52,
          size.width * 0.80, size.height * 0.62)
      ..lineTo(size.width * 0.70, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.76, size.height * 0.50,
          size.width * 0.68, size.height * 0.42)
      ..close();
    canvas.drawPath(rightArm, paintOrange);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.42, size.height * 0.28, size.width * 0.16,
            size.height * 0.10),
        const Radius.circular(4),
      ),
      paintSkin,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.50, size.height * 0.20),
        width: size.width * 0.34,
        height: size.width * 0.36,
      ),
      paintSkin,
    );

    final hair = Paint()..color = darkBlue;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import 'sign_up.dart';
import 'signin_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;
    final topPad = mq.padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1A2E),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_ctrl.value);

          final bH = _lerp(200.0, 58.0, t);
          final bW = _lerp(200.0, 190.0, t);
          final bLeft = _lerp(sw / 2 - 100, 18.0, t);
          final bTop = _lerp(sh / 2 - 100, topPad + 12.0, t);
          final bRadius = _lerp(100.0, 14.0, t);

          final contentOpacity = ((t - 0.45) / 0.55).clamp(0.0, 1.0);
          final textOpacity = ((t - 0.65) / 0.35).clamp(0.0, 1.0);

          return Stack(
            children: [
              // ── dark sky background ──────────────────────────────────────
              Positioned.fill(
                child: _SkyLayer(sw: sw, sh: sh),
              ),

              // ── fading content ───────────────────────────────────────────
              Opacity(
                opacity: contentOpacity,
                child: _buildContent(context),
              ),

              // ── animated badge ───────────────────────────────────────────
              Positioned(
                left: bLeft,
                top: bTop,
                child: Container(
                  width: bW,
                  height: bH,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(bRadius),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(bRadius),
                    child: Row(
                      children: [
                        // logo image
                        SizedBox(
                          width: bH,
                          height: bH,
                          child: Padding(
                            padding: EdgeInsets.all(bH * 0.07),
                            child: Image.asset(
                              'assets/logo3.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // text
                        Opacity(
                          opacity: textOpacity,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HOME SERVICES',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                                const Text(
                                  'GoFIX',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Color(0xFF0B1A2E),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFD4952A),
                size: 26,
              ),
              const SizedBox(height: 4),
              const Text(
                'Anything broken?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 33,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              Text(
                "We've got a pro.",
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 33,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Plumbers, electricians, carpenters,\npainters — booked in under a minute.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0x99FFFFFF),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<AuthBloc>(),
                        child: const Signup(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<AuthBloc>(),
                          child: const SigninPage(),
                        ),
                      ),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already with us? ',
                          style: TextStyle(
                            color: Color(0x99FFFFFF),
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: 'Sign in',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Sky layer with all decorative elements ───────────────────────────────────

class _SkyLayer extends StatelessWidget {
  const _SkyLayer({required this.sw, required this.sh});

  final double sw;
  final double sh;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Crescent moon
        Positioned(
          right: sw * 0.10,
          top: sh * 0.28,
          child: SizedBox(
            width: 68,
            height: 68,
            child: Stack(
              children: [
                // cream circle
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF0D9A0),
                  ),
                ),
                // dark overlay to carve crescent
                Positioned(
                  left: -20,
                  top: -16,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0B1A2E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // White star dots
        for (final s in _dots)
          Positioned(
            left: sw * s[0],
            top: sh * s[1],
            child: Container(
              width: s[2],
              height: s[2],
              decoration: const BoxDecoration(
                color: Color(0xCCFFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),

        // Orange plus signs
        for (final p in _plusses)
          Positioned(
            left: sw * p[0],
            top: sh * p[1],
            child: Text(
              '+',
              style: TextStyle(
                color: const Color(0xFFD4952A),
                fontSize: p[2] * 5.0,
                height: 1,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),

        // Buildings
        Positioned(
          left: 0,
          right: 0,
          bottom: sh * 0.22,
          height: 150,
          child: CustomPaint(painter: _BuildingsPainter()),
        ),

        // House roof outline (orange)
        Positioned(
          left: sw * 0.15,
          right: sw * 0.15,
          bottom: sh * 0.30,
          height: 100,
          child: CustomPaint(painter: _RoofPainter()),
        ),

        // Mascot / man in background (semi-transparent)
        Positioned(
          left: sw * 0.25,
          right: sw * 0.25,
          bottom: sh * 0.22,
          height: sh * 0.20,
          child: Opacity(
            opacity: 0.55,
            child: Image.asset(
              'assets/logo2.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  // white dots  [relX, relY, size]
  static const List<List<double>> _dots = [
    [0.13, 0.20, 2.5],
    [0.35, 0.15, 2.0],
    [0.55, 0.11, 2.5],
    [0.67, 0.24, 2.0],
    [0.85, 0.18, 2.0],
    [0.10, 0.46, 2.0],
    [0.76, 0.42, 2.0],
    [0.44, 0.50, 1.8],
    [0.88, 0.50, 2.0],
    [0.28, 0.55, 1.8],
  ];

  // orange + signs  [relX, relY, scale]
  static const List<List<double>> _plusses = [
    [0.06, 0.38, 2.4],
    [0.44, 0.32, 2.8],
    [0.64, 0.25, 2.2],
  ];
}

class _RoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4952A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, 0)
        ..lineTo(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _BuildingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF112240);

    // [relLeft, relTop, relWidth]
    const buildings = [
      [0.00, 0.45, 0.14],
      [0.12, 0.10, 0.12],
      [0.36, 0.20, 0.10],
      [0.54, 0.15, 0.14],
      [0.76, 0.35, 0.12],
      [0.87, 0.55, 0.13],
    ];

    for (final b in buildings) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * b[0],
          size.height * b[1],
          size.width * b[2],
          size.height * (1.0 - b[1]),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

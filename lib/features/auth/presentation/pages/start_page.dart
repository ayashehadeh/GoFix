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
      backgroundColor: const Color(0xFF0A1628),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_ctrl.value);

          // Badge: 200×200 circle → rounded rectangle badge
          final bH = _lerp(200.0, 58.0, t);
          final bW = _lerp(200.0, 195.0, t);
          final bLeft = _lerp(sw / 2 - 100, 20.0, t);
          final bTop = _lerp(sh / 2 - 100, topPad + 12.0, t);
          final bRadius = _lerp(100.0, 14.0, t);

          final contentOpacity = ((t - 0.45) / 0.55).clamp(0.0, 1.0);
          final textOpacity = ((t - 0.65) / 0.35).clamp(0.0, 1.0);

          return Stack(
            children: [
              // Night sky
              Positioned.fill(child: _NightSkyBackground(sw: sw, sh: sh)),

              // Main content fades in
              Opacity(
                opacity: contentOpacity,
                child: _buildContent(context),
              ),

              // Animated logo badge
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
                        // Logo image
                        SizedBox(
                          width: bH,
                          height: bH,
                          child: Padding(
                            padding: EdgeInsets.all(bH * 0.06),
                            child: Image.asset(
                              'assets/logo3.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // Text
                        Opacity(
                          opacity: textOpacity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  'GoFIX',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Color(0xFF0A1628),
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
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFD4952A),
                size: 28,
              ),
              const SizedBox(height: 6),
              const Text(
                'Anything broken?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              Text(
                "We've got a pro.",
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Plumbers, electricians, carpenters,\npainters — booked in under a minute.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xAAFFFFFF),
                  fontSize: 15,
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
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
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
              const SizedBox(height: 18),
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
                            color: Color(0xAAFFFFFF),
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Night sky background ────────────────────────────────────────────────────

class _NightSkyBackground extends StatelessWidget {
  const _NightSkyBackground({required this.sw, required this.sh});

  final double sw;
  final double sh;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Crescent moon ───────────────────────────────────────────────────
        Positioned(
          right: sw * 0.08,
          top: sh * 0.30,
          child: SizedBox(
            width: 74,
            height: 74,
            child: Stack(
              children: [
                // Cream circle
                Container(
                  width: 74,
                  height: 74,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF2DEB0),
                  ),
                ),
                // Dark overlay to create crescent shape
                Positioned(
                  left: -22,
                  top: -18,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0A1628),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── White star dots ─────────────────────────────────────────────────
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

        // ── Orange + plus signs ─────────────────────────────────────────────
        for (final p in _plusses)
          Positioned(
            left: sw * p[0],
            top: sh * p[1],
            child: Text(
              '+',
              style: TextStyle(
                color: const Color(0xFFD4952A),
                fontSize: p[2] * 4.5,
                height: 1,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),

        // ── City buildings ──────────────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: sh * 0.25,
          height: 140,
          child: CustomPaint(painter: _CityscapePainter()),
        ),

        // ── House roof outline ──────────────────────────────────────────────
        Positioned(
          left: sw * 0.18,
          right: sw * 0.18,
          bottom: sh * 0.27,
          height: 90,
          child: CustomPaint(painter: _RoofPainter()),
        ),

        // ── Mascot / character ──────────────────────────────────────────────
        Positioned(
          left: sw * 0.28,
          right: sw * 0.28,
          bottom: sh * 0.27,
          height: sh * 0.16,
          child: Image.asset(
            'assets/logo3.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  static const List<List<double>> _dots = [
    [0.12, 0.18, 3.0],
    [0.34, 0.13, 2.5],
    [0.54, 0.09, 2.0],
    [0.65, 0.22, 2.5],
    [0.86, 0.17, 2.0],
    [0.20, 0.48, 2.0],
    [0.78, 0.43, 2.0],
    [0.44, 0.52, 1.8],
    [0.90, 0.52, 2.0],
  ];

  static const List<List<double>> _plusses = [
    [0.05, 0.40, 2.6],
    [0.44, 0.34, 3.0],
    [0.62, 0.26, 2.4],
  ];
}

// ── Painters ────────────────────────────────────────────────────────────────

class _RoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4952A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _CityscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = const Color(0xFF112240);

    const List<List<double>> buildings = [
      [0.00, 0.50, 0.13],
      [0.11, 0.15, 0.11],
      [0.35, 0.22, 0.09],
      [0.56, 0.18, 0.13],
      [0.76, 0.38, 0.11],
      [0.86, 0.58, 0.14],
    ];

    for (final b in buildings) {
      final left = size.width * b[0];
      final top = size.height * b[1];
      final w = size.width * b[2];
      final h = size.height - top;
      canvas.drawRect(Rect.fromLTWH(left, top, w, h), fill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

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
    // Brief delay so the instant navigation from _SplashRouter renders first,
    // giving the user a seamless "same frame" before animation begins.
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
      backgroundColor: AppColors.primary,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_ctrl.value);

          // Badge morphs from centered 200×200 circle → small top-left pill
          final bH = _lerp(200.0, 50.0, t);
          final bW = _lerp(200.0, 168.0, t);
          final bLeft = _lerp(sw / 2 - 100, 16.0, t);
          final bTop = _lerp(sh / 2 - 100, topPad + 16.0, t);
          final bRadius = bH / 2; // always perfectly rounded

          final contentOpacity =
              ((t - 0.45) / 0.55).clamp(0.0, 1.0);
          final textOpacity =
              ((t - 0.65) / 0.35).clamp(0.0, 1.0);

          return Stack(
            children: [
              // ── static background (always visible) ──────────────────────
              Positioned.fill(child: _NightSkyBackground(sw: sw, sh: sh)),

              // ── fading content ───────────────────────────────────────────
              Opacity(
                opacity: contentOpacity,
                child: _buildContent(context, sw, sh),
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
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Logo circle fills the full height of the badge
                      SizedBox(
                        width: bH,
                        height: bH,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(bRadius),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Text panel fades in when badge is almost a pill
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
                                  fontSize: 8,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                'GoFix',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, double sw, double sh) {
    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFAA00), size: 30),
              const SizedBox(height: 8),
              const Text(
                'Anything broken?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              Text(
                "We've got a pro.",
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Plumbers, electricians, carpenters,\npainters — booked in under a minute.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.70),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              // Get Started → Signup
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
                  elevation: 4,
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
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already with us? ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
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

// ── Night-sky background ─────────────────────────────────────────────────────

class _NightSkyBackground extends StatelessWidget {
  const _NightSkyBackground({required this.sw, required this.sh});

  final double sw;
  final double sh;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Moon
        Positioned(
          right: 44,
          top: sh * 0.30,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFB8C8E8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB8C8E8).withOpacity(0.35),
                  blurRadius: 24,
                  spreadRadius: 6,
                ),
              ],
            ),
          ),
        ),

        // Stars — dots
        for (final s in _dots)
          Positioned(
            left: sw * s[0],
            top: sh * s[1],
            child: Container(
              width: s[2],
              height: s[2],
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.65),
                shape: BoxShape.circle,
              ),
            ),
          ),

        // Stars — plus signs
        for (final p in _plusses)
          Positioned(
            left: sw * p[0],
            top: sh * p[1],
            child: Text(
              '+',
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: p[2] * 3.5,
                height: 1,
              ),
            ),
          ),

        // City skyline at bottom of sky section
        Positioned(
          left: 0,
          right: 0,
          bottom: sh * 0.32,
          height: 110,
          child: CustomPaint(painter: _CityscapePainter()),
        ),
      ],
    );
  }

  static const _dots = [
    [0.08, 0.14, 2.5],
    [0.28, 0.09, 2.0],
    [0.50, 0.07, 3.0],
    [0.68, 0.17, 2.0],
    [0.83, 0.11, 2.5],
    [0.92, 0.33, 2.0],
    [0.22, 0.44, 2.0],
    [0.76, 0.39, 2.5],
    [0.40, 0.52, 1.8],
    [0.60, 0.48, 2.0],
  ];

  static const _plusses = [
    [0.14, 0.34, 2.2],
    [0.58, 0.24, 2.5],
    [0.88, 0.20, 2.0],
  ];
}

class _CityscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = const Color(0xFF0D2040);
    final window = Paint()
      ..color = const Color(0xFFFFD080).withOpacity(0.35);

    // [relLeft, relTop, relWidth]  (height goes to bottom)
    const buildings = [
      [0.00, 0.60, 0.07],
      [0.06, 0.28, 0.06],
      [0.11, 0.48, 0.10],
      [0.20, 0.08, 0.11],
      [0.30, 0.38, 0.08],
      [0.37, 0.18, 0.13],
      [0.49, 0.55, 0.09],
      [0.57, 0.22, 0.08],
      [0.64, 0.42, 0.11],
      [0.74, 0.12, 0.10],
      [0.83, 0.48, 0.08],
      [0.90, 0.30, 0.07],
      [0.96, 0.58, 0.04],
    ];

    for (final b in buildings) {
      final left = size.width * b[0];
      final top = size.height * b[1];
      final w = size.width * b[2];
      final h = size.height - top;
      canvas.drawRect(Rect.fromLTWH(left, top, w, h), fill);

      // A few lit windows per building
      for (var row = 0; row < 4; row++) {
        for (var col = 0; col < 2; col++) {
          if ((row + col).isEven) continue;
          final wx = left + w * 0.15 + col * w * 0.45;
          final wy = top + 6 + row * 12.0;
          if (wy + 5 > size.height) continue;
          canvas.drawRect(Rect.fromLTWH(wx, wy, 3.0, 4.5), window);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

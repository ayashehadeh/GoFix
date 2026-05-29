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
              // Sky background with all scene elements
              Positioned.fill(child: _SkyLayer(sw: sw, sh: sh)),

              // Bottom content fades in
              Opacity(opacity: contentOpacity, child: _buildContent(context)),

              // Animated badge (circle → pill)
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
                        SizedBox(
                          width: bH,
                          height: bH,
                          child: Padding(
                            padding: EdgeInsets.all(bH * 0.07),
                            child: Image.asset(
                              'assets/gofix-logo-color.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
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
              const Icon(Icons.star_rounded, color: Color(0xFFD4952A), size: 26),
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
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<AuthBloc>(),
                      child: const Signup(),
                    ),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<AuthBloc>(),
                        child: const SigninPage(),
                      ),
                    ));
                  },
                  child: RichText(
                    text: const TextSpan(children: [
                      TextSpan(
                        text: 'Already with us? ',
                        style:
                            TextStyle(color: Color(0x99FFFFFF), fontSize: 14),
                      ),
                      TextSpan(
                        text: 'Sign in',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ]),
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

// ── Sky layer ────────────────────────────────────────────────────────────────

class _SkyLayer extends StatelessWidget {
  const _SkyLayer({required this.sw, required this.sh});

  final double sw;
  final double sh;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Moon image
        Positioned(
          right: sw * 0.08,
          top: sh * 0.26,
          width: sw * 0.22,
          height: sw * 0.22,
          child: Image.asset('assets/scene-moon.png', fit: BoxFit.contain),
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

        // City buildings
        Positioned(
          left: 0,
          right: 0,
          bottom: sh * 0.22,
          height: 150,
          child: CustomPaint(painter: _BuildingsPainter()),
        ),

        // House scene
        Positioned(
          left: sw * 0.10,
          right: sw * 0.10,
          bottom: sh * 0.28,
          height: sh * 0.22,
          child: Image.asset('assets/scene-house.png', fit: BoxFit.contain),
        ),

        // Handyman / character
        Positioned(
          left: sw * 0.28,
          right: sw * 0.28,
          bottom: sh * 0.25,
          height: sh * 0.20,
          child: Image.asset('assets/scene-handyman.png', fit: BoxFit.contain),
        ),
      ],
    );
  }

  static const List<List<double>> _dots = [
    [0.13, 0.18, 2.5],
    [0.35, 0.13, 2.0],
    [0.55, 0.09, 2.5],
    [0.67, 0.22, 2.0],
    [0.85, 0.16, 2.0],
    [0.10, 0.44, 2.0],
    [0.76, 0.40, 2.0],
    [0.44, 0.48, 1.8],
    [0.88, 0.48, 2.0],
    [0.28, 0.53, 1.8],
  ];

  static const List<List<double>> _plusses = [
    [0.06, 0.36, 2.4],
    [0.44, 0.30, 2.8],
    [0.64, 0.23, 2.2],
  ];
}

class _BuildingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF112240);
    for (final b in const [
      [0.00, 0.45, 0.14],
      [0.12, 0.10, 0.12],
      [0.36, 0.20, 0.10],
      [0.54, 0.15, 0.14],
      [0.76, 0.35, 0.12],
      [0.87, 0.55, 0.13],
    ]) {
      canvas.drawRect(
        Rect.fromLTWH(size.width * b[0], size.height * b[1],
            size.width * b[2], size.height * (1.0 - b[1])),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

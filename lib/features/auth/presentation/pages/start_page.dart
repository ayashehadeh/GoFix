import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import 'sign_up.dart';
import 'signin_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _logoSlide;
  Animation<double>? _logoFade;

  bool _sheetVisible = false;

  @override
  void initState() {
    super.initState();

    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoSlide = Tween<double>(begin: 0.30, end: 0.0).animate(
      CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: ctrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _controller = ctrl;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      ctrl.forward().then((_) {
        if (!mounted) return;
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          setState(() => _sheetVisible = true);
        });
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _goSignIn() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: const SigninPage(),
        ),
      ),
    );
  }

  void _goSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: const Signup(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final ctrl = _controller;
    final slide = _logoSlide;
    final fade = _logoFade;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF5EC),
      body: Stack(
        children: [
          // ── Logo ──────────────────────────────────────────────────────
          if (ctrl != null && slide != null && fade != null)
            AnimatedBuilder(
              animation: ctrl,
              builder: (context, child) {
                return FractionalTranslation(
                  translation: Offset(0, slide.value),
                  child: Opacity(
                    opacity: fade.value,
                    child: child,
                  ),
                );
              },
              child: Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 110),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/logo2edit.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported,
                                  size: 60,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'GoFix',
                          style: TextStyle(
                            color: Color(0xFF062B54),
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'HOME SERVICES',
                          style: TextStyle(
                            color: Color(0xFFFF8C1A),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 3.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── Welcome bottom sheet ───────────────────────────────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: _sheetVisible ? 0 : -340,
            child: _WelcomeSheet(
              onSignIn: _goSignIn,
              onSignUp: _goSignUp,
              t: t,
            ),
          ),
        ],
      ),
      
    );
  }
}

// ── Welcome bottom sheet ───────────────────────────────────────────────────────

class _WelcomeSheet extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;
  final AppLocalizations t;

  const _WelcomeSheet({
    required this.onSignIn,
    required this.onSignUp,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 48),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            t.hello,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF062B54),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            t.startSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF062B54),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    t.signIn,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: onSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C1A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    t.signUp,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

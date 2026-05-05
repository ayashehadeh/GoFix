import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/application_status_bloc.dart';
import '../bloc/application_status_event.dart';
import 'approval_status_screen.dart';

class InQueuePage extends StatelessWidget {
  const InQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // ── Illustration ───────────────────────────────────────────
              SvgPicture.asset(
                'assets/inqueue_phone.svg',
                height: 220,
              ),

              const SizedBox(height: 32),

              // ── Title ──────────────────────────────────────────────────
              const Text(
                "You're In the Queue!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "We've received your application and will review it "
                "within 24-48 hours. You'll get a notification once "
                "your profile is approved and ready to go live.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(),

              // ── Check Status ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => di.sl<ApplicationStatusBloc>()
                            ..add(const LoadApplicationStatus()),
                          child: const ApprovalStatusScreen(),
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryOrange,
                    side: const BorderSide(
                      color: AppColors.primaryOrange,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Check Status',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Done ───────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil('/home', (_) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

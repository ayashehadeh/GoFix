// lib/features/bookings/presentation/pages/booking_success_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/home/presentation/bloc/home_bloc.dart';
import 'package:gp/features/home/presentation/pages/home_page.dart';
import 'package:gp/injection_container.dart' as di;
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

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
                    Text(
                      "We've Got It From Here!",
                      style: AppTextStyles.heading1.copyWith(
                        fontSize: 26,
                        color: AppColors.primaryDark,
                        height: 1.2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your request is now pending. Please allow some time for the professional to review the details. You can track the status of this request in the "My Bookings" section.',
                      textAlign: TextAlign.justify,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 14,
                        height: 1.7,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Image.asset(
                        'assets/successbook.png',
                        width: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        'We appreciate your trust in\nour service.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.sectionTitle.copyWith(
                          color: AppColors.primaryDark,
                          height: 1.5,
                          decoration: TextDecoration.none,
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
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Done',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 0.5,
                      decoration: TextDecoration.none,
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
}

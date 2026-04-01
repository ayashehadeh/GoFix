import 'package:flutter/material.dart';
import 'start_page.dart';
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/l10n/app_localizations.dart';

class Created extends StatelessWidget {
  const Created({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.accountCreated,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                t.welcomeToApp,
                style: TextStyle(fontSize: 16, color: AppColors.primary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),
              Image.asset('assets/account_verified.png', height: 250),

              const SizedBox(height: 40),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: t.accountCreatedLine1,
                  style: TextStyle(fontSize: 16, color: AppColors.primary),
                  children: [
                    TextSpan(
                      text: t.successfully,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const StartPage(),
                      ),
                    );
                  },
                  child: Text(
                    t.continue1,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

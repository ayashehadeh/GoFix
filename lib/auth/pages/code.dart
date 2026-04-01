import 'package:flutter/material.dart';
import 'created.dart';
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/l10n/app_localizations.dart';

/// Email verification screen shown after registration.
/// The user enters the 4-digit OTP sent to their email address.
///
/// NOTE: The "Continue" button currently navigates to [Created] without
/// verifying the code against the backend (GET /auth/verify-email).
/// The OTP field controllers and the API call still need to be wired up.
class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),

      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              Text(
                t.verifyEmail,
                textAlign: TextAlign.right,

                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                t.verifyEmailDesc,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.primary, fontSize: 18),
              ),

              const SizedBox(height: 20),

              Image.asset('assets/email_verification.png', height: 250),
              const SizedBox(height: 20),

              const SizedBox(height: 40),

              // Four single-character OTP input boxes.
              // TODO: wire up controllers and auto-focus next box on input.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 55,
                    height: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 50),

              // TODO: verify OTP via GET /auth/verify-email before navigating.
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Created()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    t.didNotReceiveCode,
                    style: TextStyle(color: Colors.grey),
                  ),
                  // TODO: implement resend OTP request to backend.
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      t.sendAgain,
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

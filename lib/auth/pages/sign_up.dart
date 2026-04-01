import 'package:flutter/material.dart';
import 'code.dart';
import 'package:gp/core/theme/app_colors.dart';
import 'package:gp/l10n/app_localizations.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(backgroundColor: AppColors.primary, elevation: 0),
      body: SafeArea(
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset('assets/logo2.png', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.firstName, style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 7),

                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Text(t.lastName, style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 7),

                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Text(t.enterPhone, style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 7),

                      TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone_android),
                          hintText: t.phoneHint,
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(t.enterEmail, style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 7),

                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(t.password, style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 7),

                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        t.confirmPassword,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 7),

                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const VerifyEmailPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          t.signUp,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: t.alreadyHaveAccount,
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: " Sign in",
                                style: TextStyle(
                                  color: AppColors.accent,
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
        ),
      ),
    );
  }
}

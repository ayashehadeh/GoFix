import 'package:flutter/material.dart';
import 'package:gp/features/home/presentation/pages/home_page.dart';

class InQueue extends StatelessWidget {
  const InQueue({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              const Text(
                "You're In the Queue!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF062B54),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "We've received your application and will review it within 24 to 48 hours. You'll get a notification once your profile is approved and ready to go live.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF062B54),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 80),

              Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  'assets/done.png',
                  height: 320,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 150),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "Done",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

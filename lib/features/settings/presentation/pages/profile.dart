import 'package:flutter/material.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/widgets/gofix_bottom_nav_bar.dart';
import 'package:gp/auth/become a professional/pages/stepper_screen.dart';
import 'package:gp/features/settings/presentation/pages/personal_information_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileView();
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Widget menuItem(
    BuildContext context,
    IconData icon,
    String text, {
    String? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF062B4D)),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(fontSize: 16, color: Color(0xFF062B4D)),
            ),
            const Spacer(),
            trailing != null
                ? Text(
                    trailing,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF062B4D),
                    ),
                  )
                : const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF062B4D),
                  ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF062B4D),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hazim Amir',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF062B4D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  sectionTitle("Your account"),
                  menuItem(
                    context,
                    Icons.person,
                    "Personal information",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PersonalInformationPage(),
                      ),
                    ),
                  ),
                  menuItem(context, Icons.notifications, "Notifications"),
                  menuItem(context, Icons.key, "Password"),
                  menuItem(context, Icons.location_on, "Your addresses"),
                  menuItem(context, Icons.cancel, "Delete account"),
                  menuItem(context, Icons.logout, "Log out"),
                  const Divider(),
                  sectionTitle("Support"),
                  menuItem(context, Icons.help_outline, "Help & Support"),
                  menuItem(
                    context,
                    Icons.build,
                    "Become a professional",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StepperScreen(),
                      ),
                    ),
                  ),
                  menuItem(context, Icons.feedback, "Send Feedback"),
                  const Divider(),
                  sectionTitle("Preferences"),
                  menuItem(context, Icons.language, "Language", trailing: "EN"),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: GoFixBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/bookings');
          if (index == 2) return;
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/home/presentation/bloc/home_bloc.dart';
import 'package:gp/features/home/presentation/pages/home_page.dart';
import 'package:gp/injection_container.dart' as di;
import '../widgets/step_indicator.dart';
import 'professional_details1.dart';
import 'professional_details2.dart';
import 'professional_details3.dart';
import 'in_queue.dart';

class StepperScreen extends StatefulWidget {
  const StepperScreen({super.key});

  @override
  State<StepperScreen> createState() => _StepperScreenState();
}

class _StepperScreenState extends State<StepperScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  void goToPage(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void goToInQueue() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const InQueue()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF062B4D),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 50),

                    StepIndicator(
                      currentStep: currentPage,
                      onStepTapped: goToPage,
                    ),
                    const SizedBox(height: 11),

                    Expanded(
                      child: PageView(
                        controller: _controller,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            currentPage = index;
                          });
                        },
                        children: [
                          ProfessionalDetailsPage(
                            onContinue: () => goToPage(1), // ✅ step 1 → 2
                          ),
                          PageTwo(
                            onContinue: () => goToPage(2), // ✅ step 2 → 3
                          ),
                          PageThree(
                            onContinue: goToInQueue, // ✅ step 3 → InQueue
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
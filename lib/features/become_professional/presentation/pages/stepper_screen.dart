import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/become_professional_bloc.dart';
import '../bloc/become_professional_event.dart';
import '../bloc/become_professional_state.dart';
import '../widgets/step_indicator.dart';
import 'professional_details1_page.dart';
import 'professional_details2_page.dart';
import 'professional_details3_page.dart';
import 'in_queue_page.dart';

class StepperScreen extends StatefulWidget {
  const StepperScreen({super.key});

  @override
  State<StepperScreen> createState() => _StepperScreenState();
}

class _StepperScreenState extends State<StepperScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _goToPage(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BecomeProfessionalBloc, BecomeProfessionalState>(
      listener: (context, state) {
        if (state is BecomeProfessionalSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const InQueuePage()),
          );
        }
        if (state is BecomeProfessionalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
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
                        currentStep: _currentPage,
                        onStepTapped: _goToPage,
                      ),
                      const SizedBox(height: 11),
                      Expanded(
                        child: PageView(
                          controller: _controller,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (i) =>
                              setState(() => _currentPage = i),
                          children: [
                            ProfessionalDetails1Page(
                              onContinue: () => _goToPage(1),
                            ),
                            ProfessionalDetails2Page(
                              onContinue: () => _goToPage(2),
                            ),
                            ProfessionalDetails3Page(
                              onSubmit: () => context
                                  .read<BecomeProfessionalBloc>()
                                  .add(SubmitApplication()),
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
      ),
    );
  }
}

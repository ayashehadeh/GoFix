import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/become_professional/presentation/bloc/become_professional_event.dart';
import 'package:gp/injection_container.dart' as di;
import '../bloc/become_professional_bloc.dart';
import '../bloc/become_professional_state.dart';
import '../widgets/step_indicator.dart';
import 'professional_details1_page.dart';
import 'professional_details2_page.dart';
import 'professional_details3_page.dart';
import 'in_queue_page.dart';

class StepperScreen extends StatelessWidget {
  const StepperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<BecomeProfessionalBloc>(),
      child: const _StepperBody(),
    );
  }
}

class _StepperBody extends StatefulWidget {
  const _StepperBody();

  @override
  State<_StepperBody> createState() => _StepperBodyState();
}

class _StepperBodyState extends State<_StepperBody> {
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
              // Back button
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      if (_currentPage > 0) {
                        _goToPage(_currentPage - 1);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    children: [
                      StepIndicator(
                        currentStep: _currentPage,
                        onStepTapped: _goToPage,
                      ),
                      const SizedBox(height: 20),
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

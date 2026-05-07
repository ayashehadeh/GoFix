import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/become_professional_bloc.dart';
import '../bloc/become_professional_event.dart';
import '../bloc/become_professional_state.dart';
import '../widgets/step_indicator.dart';
import 'in_queue_page.dart';
import 'professional_details_page.dart';
import 'services_pricing_page.dart';
import 'verification_upload_page.dart';

/// Entry page for the Become Professional flow.
/// Steps:
///   0 – Professional Details (category, experience, city, service areas, bio)
///   1 – Services & Pricing
///   2 – Verification / Documents
class StepperScreen extends StatelessWidget {
  const StepperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          di.sl<BecomeProfessionalBloc>()..add(const LoadInitialData()),
      child: const _StepperScreenView(),
    );
  }
}

class _StepperScreenView extends StatefulWidget {
  const _StepperScreenView();

  @override
  State<_StepperScreenView> createState() => _StepperScreenViewState();
}

class _StepperScreenViewState extends State<_StepperScreenView> {
  final _controller = PageController();
  int _currentStep = 0;

  void _goToStep(int step) {
    if (step < 0 || step > 2) return;
    setState(() => _currentStep = step);
    _controller.animateToPage(
      step,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<bool> _handleBack() async {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
      return false;
    }
    return true;
  }

  void _onSubmitted() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const InQueuePage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocListener<BecomeProfessionalBloc, BecomeProfessionalState>(
            listenWhen: (prev, curr) =>
                prev.errorMessage != curr.errorMessage &&
                curr.errorMessage != null,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StepIndicator(currentStep: _currentStep),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PageView(
                      controller: _controller,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Step 0 – details + service areas
                        ProfessionalDetailsPage(
                          onContinue: () => _goToStep(1),
                        ),
                        // Step 1 – services & pricing
                        ServicesPricingPage(
                          onContinue: () => _goToStep(2),
                        ),
                        // Step 2 – documents & submit
                        VerificationUploadPage(
                          onSubmitted: _onSubmitted,
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
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
                onPressed: () async {
                  if (await _handleBack()) {
                    if (mounted) Navigator.of(context).pop();
                  }
                },
              ),
              const Expanded(
                child: Text(
                  'Become a Professional',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }
}

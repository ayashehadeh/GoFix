import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/features/become_professional/presentation/bloc/become_professional_bloc.dart';
import 'package:gp/features/become_professional/presentation/bloc/become_professional_event.dart';
import 'package:gp/features/become_professional/presentation/bloc/become_professional_state.dart';
import 'package:gp/core/utils/snackbar_helper.dart';
import 'package:gp/features/become_professional/presentation/pages/edit_verification_page.dart';
import 'package:gp/features/become_professional/presentation/pages/professional_details_page.dart';
import 'package:gp/features/become_professional/presentation/pages/profile_updated_page.dart';
import 'package:gp/features/become_professional/presentation/pages/services_pricing_page.dart';
import 'package:gp/features/become_professional/presentation/widgets/step_indicator.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/injection_container.dart' as di;

class EditProfileStepper extends StatelessWidget {
  final Professional professional;

  const EditProfileStepper({super.key, required this.professional});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<BecomeProfessionalBloc>()
        ..add(PreloadProfileData(professional))
        ..add(const LoadInitialData()),
      child: _EditProfileStepperView(professional: professional),
    );
  }
}

class _EditProfileStepperView extends StatefulWidget {
  final Professional professional;
  const _EditProfileStepperView({required this.professional});

  @override
  State<_EditProfileStepperView> createState() =>
      _EditProfileStepperViewState();
}

class _EditProfileStepperViewState extends State<_EditProfileStepperView> {
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

  void _onSaved() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ProfileUpdatedPage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocListener<BecomeProfessionalBloc, BecomeProfessionalState>(
            listenWhen: (prev, curr) =>
                prev.errorMessage != curr.errorMessage &&
                curr.errorMessage != null,
            listener: (context, state) {
              showErrorSnackbar(context, state.errorMessage!);
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
                        ProfessionalDetailsPage(
                          onContinue: () => _goToStep(1),
                          isEditMode: true,
                        ),
                        ServicesPricingPage(
                          onContinue: () => _goToStep(2),
                        ),
                        EditVerificationPage(
                          professional: widget.professional,
                          onSaved: _onSaved,
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
      child: Row(
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
              'Edit Profile',
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
    );
  }
}

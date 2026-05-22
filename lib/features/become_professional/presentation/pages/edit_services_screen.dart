import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/features/become_professional/presentation/bloc/become_professional_bloc.dart';
import 'package:gp/features/become_professional/presentation/bloc/become_professional_event.dart';
import 'package:gp/features/become_professional/presentation/bloc/become_professional_state.dart';
import 'package:gp/features/become_professional/presentation/pages/profile_updated_page.dart';
import 'package:gp/features/become_professional/presentation/pages/services_pricing_page.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/injection_container.dart' as di;

class EditServicesScreen extends StatelessWidget {
  final Professional professional;

  const EditServicesScreen({super.key, required this.professional});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<BecomeProfessionalBloc>()
        ..add(PreloadProfileData(professional)),
      child: _EditServicesView(professional: professional),
    );
  }
}

class _EditServicesView extends StatelessWidget {
  final Professional professional;

  const _EditServicesView({required this.professional});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              _buildHeader(context),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ServicesPricingPage(
                    buttonLabel: 'Save Changes',
                    onContinue: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => const ProfileUpdatedPage()),
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

  Widget _buildHeader(BuildContext context) {
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
            onPressed: () => Navigator.of(context).pop(),
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

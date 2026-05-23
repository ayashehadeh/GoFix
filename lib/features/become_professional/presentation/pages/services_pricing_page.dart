import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/l10n/service_name_l10n.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/category_service.dart';
import '../../domain/entities/service_pricing.dart';
import '../bloc/become_professional_bloc.dart';
import '../bloc/become_professional_event.dart';
import '../bloc/become_professional_state.dart';
import '../widgets/step_continue_button.dart';

class ServicesPricingPage extends StatefulWidget {
  final VoidCallback onContinue;
  final String buttonLabel;

  const ServicesPricingPage({
    super.key,
    required this.onContinue,
    this.buttonLabel = 'Continue',
  });

  @override
  State<ServicesPricingPage> createState() => _ServicesPricingPageState();
}

class _ServicesPricingPageState extends State<ServicesPricingPage> {
  CategoryService? _selectedService;
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  bool _showServiceError = false;
  bool _showMinError = false;

  ActionStatus _previousStep2Status = ActionStatus.idle;

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _onAddService() {
    final service = _selectedService;
    final minText = _minController.text.trim();
    final maxText = _maxController.text.trim();

    setState(() {
      _showServiceError = service == null;
      _showMinError = minText.isEmpty || double.tryParse(minText) == null;
    });

    if (service == null || minText.isEmpty) return;
    final min = double.tryParse(minText);
    if (min == null) return;

    final max = maxText.isEmpty ? null : double.tryParse(maxText);

    context.read<BecomeProfessionalBloc>().add(
          ServiceAdded(
            ServicePricing(
              serviceId: service.id,
              serviceName: service.name,
              minPrice: min,
              maxPrice: max,
            ),
          ),
        );

    setState(() {
      _selectedService = null;
      _minController.clear();
      _maxController.clear();
    });
  }

  void _onContinuePressed() {
    final services = context.read<BecomeProfessionalBloc>().state.application.services;
    if (services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.atLeastOneService),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    context.read<BecomeProfessionalBloc>().add(const SubmitStep2());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BecomeProfessionalBloc, BecomeProfessionalState>(
      listenWhen: (prev, curr) => prev.step2Status != curr.step2Status,
      listener: (context, state) {
        if (_previousStep2Status == ActionStatus.loading &&
            state.step2Status == ActionStatus.success) {
          widget.onContinue();
        }
        _previousStep2Status = state.step2Status;
      },
      builder: (context, state) {
        final isLoading = state.step2Status == ActionStatus.loading;
        final services = state.categoryServices;
        final added = state.application.services;
        final loadingServices =
            state.categoryServicesStatus == ActionStatus.loading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Services & Pricing',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose a service',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _showServiceError
                            ? AppColors.error
                            : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (loadingServices && services.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else if (services.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.divider.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'No services available for this category.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: services.map((s) {
                          final isSel = _selectedService?.id == s.id;
                          final isAdded =
                              added.any((a) => a.serviceId == s.id);
                          return ChoiceChip(
                            label: Text(localizeServiceName(s.name, AppLocalizations.of(context)!, nameAr: s.nameAr)),
                            selected: isSel,
                            onSelected: isAdded
                                ? null
                                : (sel) => setState(() {
                                      _selectedService = sel ? s : null;
                                      _showServiceError = false;
                                    }),
                            selectedColor: AppColors.primaryOrange,
                            backgroundColor: Colors.white,
                            disabledColor:
                                AppColors.divider.withOpacity(0.4),
                            side: BorderSide(
                              color: isSel
                                  ? AppColors.primaryOrange
                                  : AppColors.divider,
                            ),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: isSel
                                  ? Colors.white
                                  : isAdded
                                      ? AppColors.textSecondary
                                      : AppColors.primaryDark,
                              fontWeight: isSel
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _PriceInput(
                            label: 'Min price (JD)',
                            controller: _minController,
                            hasError: _showMinError,
                            onChanged: (_) {
                              if (_showMinError) {
                                setState(() => _showMinError = false);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PriceInput(
                            label: 'Max price (optional)',
                            controller: _maxController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _onAddService,
                        icon: const Icon(Icons.add,
                            color: AppColors.primaryOrange),
                        label: const Text(
                          'Add service',
                          style: TextStyle(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                              color: AppColors.primaryOrange),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (added.isNotEmpty) ...[
                      const Text(
                        'Added services',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...added.map((sp) => _AddedServiceCard(
                            pricing: sp,
                            onRemove: () => context
                                .read<BecomeProfessionalBloc>()
                                .add(ServiceRemoved(sp.serviceId)),
                          )),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            StepContinueButton(
              onPressed: _onContinuePressed,
              isLoading: isLoading,
              label: widget.buttonLabel,
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _PriceInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool hasError;
  final ValueChanged<String>? onChanged;

  const _PriceInput({
    required this.label,
    required this.controller,
    this.hasError = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: hasError ? AppColors.error : AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.divider,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
            ],
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primaryDark,
            ),
            decoration: const InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddedServiceCard extends StatelessWidget {
  final ServicePricing pricing;
  final VoidCallback onRemove;

  const _AddedServiceCard({required this.pricing, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizeServiceName(pricing.serviceName, AppLocalizations.of(context)!),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pricing.priceDisplay,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

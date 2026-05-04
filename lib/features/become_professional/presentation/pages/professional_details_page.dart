import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/service_area.dart';
import '../bloc/become_professional_bloc.dart';
import '../bloc/become_professional_event.dart';
import '../bloc/become_professional_state.dart';
import '../widgets/step_continue_button.dart';
import '../widgets/step_form_field.dart';

class ProfessionalDetailsPage extends StatefulWidget {
  /// Called when Step 1 submission succeeds.
  final VoidCallback onContinue;

  const ProfessionalDetailsPage({super.key, required this.onContinue});

  @override
  State<ProfessionalDetailsPage> createState() =>
      _ProfessionalDetailsPageState();
}

class _ProfessionalDetailsPageState extends State<ProfessionalDetailsPage> {
  late final TextEditingController _bioController;

  // Field-level error flags shown when user taps Continue with empties.
  bool _showCategoryError = false;
  bool _showExperienceError = false;
  bool _showCityError = false;
  bool _showAreaError = false;
  bool _showBioError = false;

  // Track step1 status to know when to invoke onContinue.
  ActionStatus _previousStep1Status = ActionStatus.idle;

  @override
  void initState() {
    super.initState();
    final app = context.read<BecomeProfessionalBloc>().state.application;
    _bioController = TextEditingController(text: app.bio);
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _onContinuePressed() {
    final app = context.read<BecomeProfessionalBloc>().state.application;

    setState(() {
      _showCategoryError = app.categoryId == null;
      _showExperienceError = app.experienceYears == null;
      _showCityError = app.cityId == null || app.cityId == 0;
      _showAreaError = app.serviceAreaId == null || app.serviceAreaId == 0;
      _showBioError = app.bio.trim().isEmpty;
    });

    if (!app.isStep1Valid) return;
    context.read<BecomeProfessionalBloc>().add(const SubmitStep1());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BecomeProfessionalBloc, BecomeProfessionalState>(
      listenWhen: (prev, curr) => prev.step1Status != curr.step1Status,
      listener: (context, state) {
        if (_previousStep1Status == ActionStatus.loading &&
            state.step1Status == ActionStatus.success) {
          widget.onContinue();
        }
        _previousStep1Status = state.step1Status;
      },
      builder: (context, state) {
        final app = state.application;
        final isLoading = state.step1Status == ActionStatus.loading;
        final initialLoading =
            state.initialDataStatus == ActionStatus.loading &&
                state.categories.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Professional Details',
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
                    StepFormField(
                      label: 'Service category',
                      icon: Icons.work_outline,
                      hasError: _showCategoryError,
                      isLoading: initialLoading,
                      value: app.categoryName,
                      onTap: () => _pickCategory(context, state),
                    ),
                    const SizedBox(height: 12),
                    StepFormField(
                      label: 'Experience years',
                      icon: Icons.access_time_outlined,
                      hasError: _showExperienceError,
                      value: app.experienceYears == null
                          ? null
                          : app.experienceYears == 0
                              ? 'Less than a year'
                              : '${app.experienceYears} years',
                      onTap: () => _pickExperience(context, app.experienceYears),
                    ),
                    const SizedBox(height: 12),
                    StepFormField(
                      label: 'City',
                      icon: Icons.location_city_outlined,
                      hasError: _showCityError,
                      isLoading: initialLoading,
                      value: app.cityName,
                      onTap: () => _pickCity(context, state),
                    ),
                    const SizedBox(height: 12),
                    StepFormField(
                      label: 'Area',
                      icon: Icons.map_outlined,
                      hasError: _showAreaError,
                      enabled: app.cityId != null && app.cityId != 0,
                      value: app.serviceAreaName,
                      onTap: () => _pickArea(context, state),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Introduce Yourself',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _showBioError
                            ? AppColors.error
                            : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showBioError
                              ? AppColors.error
                              : AppColors.divider,
                        ),
                      ),
                      child: TextField(
                        controller: _bioController,
                        maxLines: 5,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryDark,
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              'This will appear as your bio on your public profile.',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                        onChanged: (value) {
                          context
                              .read<BecomeProfessionalBloc>()
                              .add(BioChanged(value));
                          if (_showBioError && value.trim().isNotEmpty) {
                            setState(() => _showBioError = false);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            StepContinueButton(
              onPressed: _onContinuePressed,
              isLoading: isLoading,
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  // ── Pickers ────────────────────────────────────────────────────────────────

  void _pickCategory(BuildContext context, BecomeProfessionalState state) {
    if (state.categories.isEmpty) return;
    final selected = state.categories.firstWhere(
      (c) => c.id == state.application.categoryId,
      orElse: () => state.categories.first,
    );
    showStepPicker<Category>(
      context: context,
      title: 'Service Category',
      items: state.categories,
      labelOf: (c) => c.name,
      selected: state.application.categoryId == null ? null : selected,
      onSelected: (cat) {
        context.read<BecomeProfessionalBloc>().add(
              CategorySelected(categoryId: cat.id, categoryName: cat.name),
            );
        setState(() => _showCategoryError = false);
      },
    );
  }

  void _pickExperience(BuildContext context, int? current) {
    final items = List.generate(51, (i) => i);
    showStepPicker<int>(
      context: context,
      title: 'Experience Years',
      items: items,
      labelOf: (e) => e == 0 ? 'Less than a year' : '$e years',
      selected: current,
      onSelected: (v) {
        context.read<BecomeProfessionalBloc>().add(ExperienceYearsSelected(v));
        setState(() => _showExperienceError = false);
      },
    );
  }

  void _pickCity(BuildContext context, BecomeProfessionalState state) {
    final cities = state.derivedCities;
    if (cities.isEmpty) return;
    final currentId = state.application.cityId;
    final selected = currentId == null
        ? null
        : cities.firstWhere(
            (c) => c.id == currentId,
            orElse: () => cities.first,
          );
    showStepPicker<({int id, String name})>(
      context: context,
      title: 'Select City',
      items: cities,
      labelOf: (c) => c.name,
      selected: selected,
      onSelected: (city) {
        context
            .read<BecomeProfessionalBloc>()
            .add(CitySelected(cityId: city.id, cityName: city.name));
        setState(() {
          _showCityError = false;
          _showAreaError = false;
        });
      },
    );
  }

  void _pickArea(BuildContext context, BecomeProfessionalState state) {
    final areas = state.areasForSelectedCity;
    if (areas.isEmpty) return;
    final currentId = state.application.serviceAreaId;
    final selected = currentId == null || currentId == 0
        ? null
        : areas.firstWhere(
            (a) => a.id == currentId,
            orElse: () => areas.first,
          );
    showStepPicker<ServiceArea>(
      context: context,
      title: 'Select Area',
      items: areas,
      labelOf: (a) => a.name,
      selected: selected,
      onSelected: (area) {
        context.read<BecomeProfessionalBloc>().add(
              ServiceAreaSelected(
                serviceAreaId: area.id,
                serviceAreaName: area.name,
              ),
            );
        setState(() => _showAreaError = false);
      },
    );
  }
}

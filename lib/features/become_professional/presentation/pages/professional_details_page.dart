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
  final VoidCallback onContinue;
  const ProfessionalDetailsPage({super.key, required this.onContinue});

  @override
  State<ProfessionalDetailsPage> createState() =>
      _ProfessionalDetailsPageState();
}

class _ProfessionalDetailsPageState extends State<ProfessionalDetailsPage> {
  late final TextEditingController _bioController;

  bool _showCategoryError = false;
  bool _showExperienceError = false;
  bool _showBioError = false;
  bool _showServiceAreaError = false;

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
      _showBioError = app.bio.trim().isEmpty;
      _showServiceAreaError = app.selectedServiceAreaIds.isEmpty;
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

        // Show areas for the selected city, fall back to all areas
        final areas = state.areasForSelectedCity.isNotEmpty
            ? state.areasForSelectedCity
            : state.allAreas;

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
                    // ── Category ─────────────────────────────────────────
                    StepFormField(
                      label: 'Service category',
                      icon: Icons.work_outline,
                      hasError: _showCategoryError,
                      isLoading: initialLoading,
                      value: app.categoryName,
                      onTap: () => _pickCategory(context, state),
                    ),
                    const SizedBox(height: 12),

                    // ── Experience ───────────────────────────────────────
                    StepFormField(
                      label: 'Experience years',
                      icon: Icons.access_time_outlined,
                      hasError: _showExperienceError,
                      value: app.experienceYears == null
                          ? null
                          : app.experienceYears == 0
                              ? 'Less than a year'
                              : '${app.experienceYears} years',
                      onTap: () =>
                          _pickExperience(context, app.experienceYears),
                    ),
                    const SizedBox(height: 12),

                    // ── City (optional, used for lat/lon coords only) ─────
                    StepFormField(
                      label: 'City (optional)',
                      icon: Icons.location_city_outlined,
                      isLoading: initialLoading,
                      value: app.cityName,
                      onTap: () => _pickCity(context, state),
                    ),
                    const SizedBox(height: 20),

                    // ── Service Areas ────────────────────────────────────
                    Row(
                      children: [
                        Text(
                          'Service Areas',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _showServiceAreaError
                                ? AppColors.error
                                : AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(select at least one)',
                          style: TextStyle(
                            fontSize: 11,
                            color: _showServiceAreaError
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (initialLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      )
                    else if (areas.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.divider.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'No service areas available.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _showServiceAreaError
                                ? AppColors.error
                                : AppColors.divider,
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          children:
                              areas.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final area = entry.value;
                            final isSelected = app.selectedServiceAreaIds
                                .contains(area.id);
                            final isLast = idx == areas.length - 1;
                            return _AreaCheckTile(
                              area: area,
                              isSelected: isSelected,
                              isLast: isLast,
                              onTap: () {
                                context
                                    .read<BecomeProfessionalBloc>()
                                    .add(ServiceAreaToggled(
                                      serviceAreaId: area.id,
                                      serviceAreaName: area.name,
                                    ));
                                if (_showServiceAreaError) {
                                  setState(() =>
                                      _showServiceAreaError = false);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),

                    if (app.selectedServiceAreaIds.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${app.selectedServiceAreaIds.length} area${app.selectedServiceAreaIds.length > 1 ? 's' : ''} selected',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // ── Bio ──────────────────────────────────────────────
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

  void _pickCategory(
      BuildContext context, BecomeProfessionalState state) {
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
              CategorySelected(
                  categoryId: cat.id, categoryName: cat.name),
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
        context
            .read<BecomeProfessionalBloc>()
            .add(ExperienceYearsSelected(v));
        setState(() => _showExperienceError = false);
      },
    );
  }

  void _pickCity(
      BuildContext context, BecomeProfessionalState state) {
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
        context.read<BecomeProfessionalBloc>().add(
              CitySelected(cityId: city.id, cityName: city.name),
            );
      },
    );
  }
}

// ── Area check tile ───────────────────────────────────────────────────────────

class _AreaCheckTile extends StatelessWidget {
  final ServiceArea area;
  final bool isSelected;
  final bool isLast;
  final VoidCallback onTap;

  const _AreaCheckTile({
    required this.area,
    required this.isSelected,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(12),
            bottom: isLast ? const Radius.circular(12) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primaryOrange
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryOrange
                          : AppColors.divider,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 12)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    area.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1, indent: 46, color: AppColors.divider),
      ],
    );
  }
}

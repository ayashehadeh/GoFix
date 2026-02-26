import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/core/widgets/custom_button.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_bloc.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_event.dart';

class FilterPage extends StatefulWidget {
  final ServiceCategory category;

  const FilterPage({super.key, required this.category});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  int? _selectedExperience;
  double _maxDistance = 8;
  double? _selectedRating;

  final List<int> _experienceOptions = [1, 3, 5, 10];
  final List<double> _ratingOptions = [2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 28,
              left: 20,
              right: 20,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.tune,
                      color: AppColors.primaryOrange, size: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.category.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.category.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // ── Filter Body ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Apply Filters', style: AppTextStyles.heading2),
                    const SizedBox(height: 24),

                    // ── Experience Years ────────────────────────────
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: AppColors.primaryOrange, size: 18),
                        const SizedBox(width: 8),
                        Text('Experience Years',
                            style: AppTextStyles.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: _experienceOptions.map((years) {
                        final selected = _selectedExperience == years;
                        return GestureDetector(
                          onTap: () => setState(() =>
                              _selectedExperience =
                                  selected ? null : years),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryOrange
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primaryOrange
                                    : AppColors.divider,
                              ),
                            ),
                            child: Text(
                              '$years+',
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 16),

                    // ── Maximum Distance ────────────────────────────
                    Row(
                      children: [
                        const Icon(Icons.bookmark_border,
                            color: AppColors.primaryOrange, size: 18),
                        const SizedBox(width: 8),
                        Text('Maximum Distance',
                            style: AppTextStyles.bodyMedium),
                        const Spacer(),
                        Text(
                          '${_maxDistance.toInt()} km',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primaryDark,
                        inactiveTrackColor: AppColors.divider,
                        thumbColor: AppColors.primaryOrange,
                        overlayColor:
                            AppColors.primaryOrange.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _maxDistance,
                        min: 1,
                        max: 30,
                        onChanged: (val) =>
                            setState(() => _maxDistance = val),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1 km', style: AppTextStyles.bodySmall),
                        Text('30 km', style: AppTextStyles.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 16),

                    // ── Minimum Rating ──────────────────────────────
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: AppColors.primaryOrange, size: 18),
                        const SizedBox(width: 8),
                        Text('Minimum Rating',
                            style: AppTextStyles.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: _ratingOptions.map((rating) {
                        final selected = _selectedRating == rating;
                        return GestureDetector(
                          onTap: () => setState(() =>
                              _selectedRating = selected ? null : rating),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryOrange
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primaryOrange
                                    : AppColors.divider,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...List.generate(
                                  rating.toInt(),
                                  (_) => Icon(
                                    Icons.star,
                                    size: 14,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.star,
                                  ),
                                ),
                                ...List.generate(
                                  5 - rating.toInt(),
                                  (_) => Icon(
                                    Icons.star_border,
                                    size: 14,
                                    color: selected
                                        ? Colors.white70
                                        : AppColors.divider,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rating == 5
                                      ? '5'
                                      : '${rating.toInt()}+',
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // ── Apply Button ────────────────────────────────
                    CustomButton(
                      text: 'Apply Filters',
                      onPressed: () {
                        context.read<ProfessionalsBloc>().add(
                              ApplyFilters(
                                category: widget.category,
                                minExperienceYears: _selectedExperience,
                                maxDistanceKm: _maxDistance,
                                minRating: _selectedRating,
                              ),
                            );
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

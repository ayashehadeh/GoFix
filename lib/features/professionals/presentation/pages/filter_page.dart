import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/core/widgets/custom_button.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_bloc.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_event.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterPage extends StatefulWidget {
  final ServiceCategory category;

  /// Pre-populate with previously active filters so the page reflects
  /// current state when reopened.
  final int? initialExperience;
  final double? initialMaxDistance;
  final double? initialRating;

  const FilterPage({
    super.key,
    required this.category,
    this.initialExperience,
    this.initialMaxDistance,
    this.initialRating,
  });

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late int? _selectedExperience;
  late double _maxDistance;
  late double? _selectedRating;

  final List<int> _experienceOptions = [1, 3, 5, 10];
  final List<double> _ratingOptions = [2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    _selectedExperience = widget.initialExperience;
    _maxDistance = widget.initialMaxDistance ?? 8;
    _selectedRating = widget.initialRating;
  }

  bool get _hasActiveFilters => _selectedExperience != null || _maxDistance != 8 || _selectedRating != null;

  void _resetAll() {
    setState(() {
      _selectedExperience = null;
      _maxDistance = 8;
      _selectedRating = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                    ),
                    // Reset button — only shown when filters are active
                    if (_hasActiveFilters)
                      GestureDetector(
                        onTap: _resetAll,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.refresh_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Reset Filters',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      widget.category.iconAsset,
                      width: 42,
                      height: 42,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryOrange,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Filter Professionals',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ── Filter options ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Minimum Experience ──────────────────────────
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium, color: AppColors.primaryOrange, size: 18),
                      const SizedBox(width: 8),
                      Text(t.expYears, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: _experienceOptions.map((years) {
                      final selected = _selectedExperience == years;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedExperience = selected ? null : years),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primaryOrange : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? AppColors.primaryOrange : AppColors.divider,
                            ),
                          ),
                          child: Text(
                            '$years+',
                            style: TextStyle(
                              color: selected ? Colors.white : AppColors.textPrimary,
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
                      const Icon(Icons.near_me, color: AppColors.primaryOrange, size: 18),
                      const SizedBox(width: 8),
                      Text(t.maximumDistance, style: AppTextStyles.bodyMedium),
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
                      overlayColor: AppColors.primaryOrange.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _maxDistance,
                      min: 1,
                      max: 30,
                      onChanged: (val) => setState(() => _maxDistance = val),
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
                      const Icon(Icons.star, color: AppColors.primaryOrange, size: 18),
                      const SizedBox(width: 8),
                      Text(t.minimumRating, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: _ratingOptions.map((rating) {
                      final selected = _selectedRating == rating;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRating = selected ? null : rating),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primaryOrange : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? AppColors.primaryOrange : AppColors.divider,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: selected ? Colors.white : AppColors.primaryOrange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating == 5 ? '5' : '${rating.toInt()}+',
                                style: TextStyle(
                                  color: selected ? Colors.white : AppColors.textPrimary,
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
                    text: t.applyFilters,
                    onPressed: () {
                      context.read<ProfessionalsBloc>().add(
                            ApplyFilters(
                              category: widget.category,
                              minExperienceYears: _selectedExperience,
                              maxDistanceKm: _maxDistance,
                              minRating: _selectedRating,
                            ),
                          );
                      // Return the active filter state back to the caller
                      Navigator.pop(
                          context,
                          FilterResult(
                            minExperience: _selectedExperience,
                            maxDistance: _maxDistance,
                            minRating: _selectedRating,
                            wasReset: false,
                          ));
                    },
                  ),

                  // ── Reset + Close (when filters active) ─────────
                  if (_hasActiveFilters) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          // Reset on server too
                          context.read<ProfessionalsBloc>().add(
                                LoadProfessionalsByCategory(widget.category),
                              );
                          Navigator.pop(
                              context,
                              const FilterResult(
                                minExperience: null,
                                maxDistance: 8,
                                minRating: null,
                                wasReset: true,
                              ));
                        },
                        child: Text(
                          'Reset Filters',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Simple result object passed back to the caller via Navigator.pop ──────────

class FilterResult {
  final int? minExperience;
  final double? maxDistance;
  final double? minRating;
  final bool wasReset;

  const FilterResult({
    required this.minExperience,
    required this.maxDistance,
    required this.minRating,
    required this.wasReset,
  });

  bool get hasActiveFilters => !wasReset && (minExperience != null || maxDistance != 8 || minRating != null);
}

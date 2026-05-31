import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/features/become_professional/domain/entities/category_service.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_bloc.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_event.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_state.dart';
import 'package:gp/core/widgets/skeletons/category_professionals_skeleton.dart';
import 'package:gp/features/professionals/presentation/pages/filter_page.dart';

import 'package:gp/features/professionals/presentation/pages/professional_detail_page.dart';
import 'package:gp/features/professionals/presentation/widgets/professional_card.dart';
import 'package:gp/injection_container.dart';
import 'package:gp/features/favorites/domain/entities/favorite_entity.dart';
import 'package:gp/features/favorites/domain/usecases/favorites_usecases.dart';
import 'package:gp/injection_container.dart' as di;
import 'package:dio/dio.dart';
import 'package:gp/features/become_professional/data/models/category_service_model.dart';

class CategoryProfessionalsPage extends StatefulWidget {
  final ServiceCategory category;
  final int? serviceId;
  final String? serviceName;

  const CategoryProfessionalsPage({
    super.key,
    required this.category,
    this.serviceId,
    this.serviceName,
  });

  @override
  State<CategoryProfessionalsPage> createState() => _CategoryProfessionalsPageState();
}

class _CategoryProfessionalsPageState extends State<CategoryProfessionalsPage> {
  final TextEditingController _searchController = TextEditingController();

  // ── Professionals state ───────────────────────────────────────────────────
  List<Professional> _allProfessionals = []; // full list from BLoC
  List<Professional> _filteredList = []; // what the list view shows

  // ── Service chips state ───────────────────────────────────────────────────
  List<CategoryService> _services = [];
  int? _selectedServiceId; // null = "All"
  bool _servicesLoading = false;

  // ── Active filter tracking (for badge + pre-populating FilterPage) ────────
  int? _activeMinExp;
  double? _activeMaxDistance;
  double? _activeMinRating;

  bool get _hasActiveFilters =>
      _activeMinExp != null || (_activeMaxDistance != null && _activeMaxDistance != 8) || _activeMinRating != null;

  @override
  void initState() {
    super.initState();
    context.read<ProfessionalsBloc>().add(LoadProfessionalsByCategory(widget.category));
    _loadServices();

    // If opened from search with a pre-selected service, honour it
    if (widget.serviceId != null) {
      _selectedServiceId = widget.serviceId;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  int _categoryIdFor(ServiceCategory cat) {
    switch (cat) {
      case ServiceCategory.plumbing:
        return 1;
      case ServiceCategory.electricalWork:
        return 2;
      case ServiceCategory.acRepair:
        return 3;
      case ServiceCategory.carpentry:
        return 4;
      case ServiceCategory.painting:
        return 5;
      case ServiceCategory.cleaning:
        return 6;
      case ServiceCategory.movingServices:
        return 7;
      case ServiceCategory.applianceRepair:
        return 8;
    }
  }

  Future<void> _loadServices() async {
    setState(() => _servicesLoading = true);
    try {
      final dio = di.sl<Dio>();
      final catId = _categoryIdFor(widget.category);
      final response = await dio.get(
        '/professionals/services',
        queryParameters: {'categoryId': catId},
      );
      final list = response.data['data'] as List? ?? [];
      final services = list.map((e) => CategoryServiceModel.fromJson(e as Map<String, dynamic>)).toList();
      if (mounted) setState(() => _services = services);
    } catch (_) {
      // Non-critical — chips just won't show if fetch fails
    } finally {
      if (mounted) setState(() => _servicesLoading = false);
    }
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  /// Called whenever either the search text or selected service chip changes.
  void _applyFilters({String? searchOverride}) {
    final query = (searchOverride ?? _searchController.text).toLowerCase().trim();

    setState(() {
      var list = _allProfessionals;

      // 1. Service chip filter
      if (_selectedServiceId != null) {
        list = list.where((p) => p.services.any((s) => s.serviceId == _selectedServiceId)).toList();
      }

      // 2. Name search filter
      if (query.isNotEmpty) {
        list = list.where((p) => p.name.toLowerCase().contains(query)).toList();
      }

      _filteredList = list;
    });
  }

  void _onSearch(String query) => _applyFilters(searchOverride: query);

  void _onChipTap(int? serviceId) {
    setState(() => _selectedServiceId = serviceId);
    _applyFilters();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<ProfessionalsBloc, ProfessionalsState>(
        listener: (context, state) {
          if (state is ProfessionalsLoaded) {
            setState(() {
              _allProfessionals = state.professionals;
            });
            _applyFilters();
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _CategoryHeader(category: widget.category),
              Expanded(child: _buildBody(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(ProfessionalsState state) {
    if (state is ProfessionalsLoading) {
      return const CategoryProfessionalsSkeleton();
    }

    if (state is ProfessionalsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(state.message, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ProfessionalsBloc>().add(
                    LoadProfessionalsByCategory(widget.category),
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                AppLocalizations.of(context)!.retry,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (state is ProfessionalsLoaded) {
      return Column(
        children: [
          // ── Search + Filter bar ──────────────────────────────────
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearch,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.search,
                              hintStyle: AppTextStyles.searchHint,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Filter button with active badge
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push<FilterResult>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ProfessionalsBloc>(),
                          child: FilterPage(
                            category: widget.category,
                            initialExperience: _activeMinExp,
                            initialMaxDistance: _activeMaxDistance,
                            initialRating: _activeMinRating,
                          ),
                        ),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        if (result.wasReset) {
                          _activeMinExp = null;
                          _activeMaxDistance = null;
                          _activeMinRating = null;
                        } else {
                          _activeMinExp = result.minExperience;
                          _activeMaxDistance = result.maxDistance;
                          _activeMinRating = result.minRating;
                        }
                      });
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _hasActiveFilters ? AppColors.primaryOrange.withOpacity(0.10) : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _hasActiveFilters ? AppColors.primaryOrange : AppColors.divider,
                          ),
                        ),
                        child: Icon(
                          Icons.tune,
                          color: _hasActiveFilters ? AppColors.primaryOrange : AppColors.primaryDark,
                          size: 22,
                        ),
                      ),
                      if (_hasActiveFilters)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryOrange,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check,
                                size: 9,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Service chips ────────────────────────────────────────
          if (_servicesLoading)
            Container(
              height: 44,
              color: AppColors.white,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),
            )
          else if (_services.isNotEmpty)
            _ServiceChips(
              services: _services,
              selectedServiceId: _selectedServiceId,
              onChipTap: _onChipTap,
            ),

          // ── Professionals list ───────────────────────────────────
          Expanded(
            child: _filteredList.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.noProfessionalsFound,
                      style: AppTextStyles.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final professional = _filteredList[index];
                      return ProfessionalCard(
                        professional: professional,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => sl<ProfessionalsBloc>(),
                                child: ProfessionalDetailPage(
                                  professionalId: professional.id,
                                  id: professional.id,
                                ),
                              ),
                            ),
                          );
                        },
                        onFavoriteTap: () async {
                          context.read<ProfessionalsBloc>().add(
                                ToggleFavoriteEvent(professional.id),
                              );
                          await di.sl<AddFavorite>()(
                            FavoriteEntity(
                              id: professional.id,
                              name: professional.name,
                              role: professional.category.displayName,
                              yearsExperience: professional.experienceYears,
                              imageUrl: professional.profileImageUrl,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

// ── Service chips row ─────────────────────────────────────────────────────────

class _ServiceChips extends StatelessWidget {
  final List<CategoryService> services;
  final int? selectedServiceId;
  final void Function(int? serviceId) onChipTap;

  const _ServiceChips({
    required this.services,
    required this.selectedServiceId,
    required this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: AppColors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: services.length + 1, // +1 for "All"
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final serviceId = isAll ? null : services[index - 1].id;
          final label = isAll ? 'All' : services[index - 1].name;
          final isActive = selectedServiceId == serviceId;

          return GestureDetector(
            onTap: () => onChipTap(serviceId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryOrange : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? AppColors.primaryOrange : AppColors.divider,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Category header ───────────────────────────────────────────────────────────

class _CategoryHeader extends StatelessWidget {
  final ServiceCategory category;

  const _CategoryHeader({required this.category});

  String _localizedName(AppLocalizations l10n) {
    switch (category) {
      case ServiceCategory.plumbing:
        return l10n.categoryPlumbing;
      case ServiceCategory.electricalWork:
        return l10n.categoryElectricalWork;
      case ServiceCategory.acRepair:
        return l10n.categoryAcRepair;
      case ServiceCategory.carpentry:
        return l10n.categoryCarpentry;
      case ServiceCategory.painting:
        return l10n.categoryPainting;
      case ServiceCategory.cleaning:
        return l10n.categoryCleaning;
      case ServiceCategory.movingServices:
        return l10n.categoryMovingServices;
      case ServiceCategory.applianceRepair:
        return l10n.categoryApplianceRepair;
    }
  }

  String _localizedDescription(AppLocalizations l10n) {
    switch (category) {
      case ServiceCategory.plumbing:
        return l10n.categoryDescPlumbing;
      case ServiceCategory.electricalWork:
        return l10n.categoryDescElectricalWork;
      case ServiceCategory.acRepair:
        return l10n.categoryDescAcRepair;
      case ServiceCategory.carpentry:
        return l10n.categoryDescCarpentry;
      case ServiceCategory.painting:
        return l10n.categoryDescPainting;
      case ServiceCategory.cleaning:
        return l10n.categoryDescCleaning;
      case ServiceCategory.movingServices:
        return l10n.categoryDescMovingServices;
      case ServiceCategory.applianceRepair:
        return l10n.categoryDescApplianceRepair;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
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
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(height: 12),
          // Category icon in white circle
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                category.iconAsset,
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
          // Category name
          Text(
            _localizedName(l10n),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          // Category description
          Text(
            _localizedDescription(l10n),
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

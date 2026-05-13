import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_bloc.dart';
import 'package:gp/features/professionals/presentation/pages/professional_detail_page.dart';
import 'package:gp/injection_container.dart' as di;
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/search_professional_card.dart';

class AreaProfessionalsPage extends StatelessWidget {
  const AreaProfessionalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        // Show loading while switching area or category
        if (state is AreaProfessionalsLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFFFCFCFC),
            body: Column(
              children: [
                _AreaHeader(
                  areaName: state.areaName,
                  city: state.city,
                  proCount: state.proCount,
                  activeCategory: null,
                ),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primaryOrange),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is AreaProfessionalsLoaded) {
          return Scaffold(
            backgroundColor: const Color(0xFFFCFCFC),
            body: Column(
              children: [
                _AreaHeader(
                  areaName: state.areaName,
                  city: state.city,
                  proCount: state.proCount,
                  activeCategory: state.activeCategory,
                ),
                _CategoryChips(activeCategory: state.activeCategory),
                Expanded(
                  child: state.professionals.isEmpty
                      ? _EmptyArea(areaName: state.areaName)
                      : _ProList(professionals: state.professionals),
                ),
              ],
            ),
          );
        }

        // Fallback — pop back if state is unexpected
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

// ─── Navy header ──────────────────────────────────────────────────────────────

class _AreaHeader extends StatelessWidget {
  final String areaName;
  final String city;
  final int proCount;
  final ServiceCategory? activeCategory;

  const _AreaHeader({
    required this.areaName,
    required this.city,
    required this.proCount,
    required this.activeCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                areaName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Filter icon (future filter page hook)
              const Icon(Icons.filter_list, color: Colors.white, size: 22),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              '$city · $proCount professional${proCount != 1 ? 's' : ''}',
              style: const TextStyle(
                color: Color(0xFFB8C5D6),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category chips ───────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final ServiceCategory? activeCategory;

  const _CategoryChips({required this.activeCategory});

  static const _chips = [
    null, // All
    ServiceCategory.plumbing,
    ServiceCategory.electricalWork,
    ServiceCategory.acRepair,
    ServiceCategory.carpentry,
    ServiceCategory.painting,
    ServiceCategory.cleaning,
    ServiceCategory.applianceRepair,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _chips[index];
          final isActive = cat == activeCategory;
          final label = cat == null ? 'All' : cat.displayName;

          return GestureDetector(
            onTap: () => context.read<SearchBloc>().add(AreaCategoryFilterChanged(cat)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryOrange : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? AppColors.primaryOrange : const Color(0xFFDDDDDD),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : const Color(0xFF555555),
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

// ─── Pro list ─────────────────────────────────────────────────────────────────

class _ProList extends StatelessWidget {
  final List<Professional> professionals;

  const _ProList({required this.professionals});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: professionals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final pro = professionals[index];
        return SearchProfessionalCard(
          professional: pro,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => di.sl<ProfessionalsBloc>(),
                child: ProfessionalDetailPage(professionalId: pro.id, id: pro.id),
              ),
            ),
          ),
          onFavoriteTap: () {},
        );
      },
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyArea extends StatelessWidget {
  final String areaName;

  const _EmptyArea({required this.areaName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off_outlined, size: 52, color: AppColors.divider),
          const SizedBox(height: 16),
          Text(
            'No professionals found in $areaName',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

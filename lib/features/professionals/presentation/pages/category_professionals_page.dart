import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_bloc.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_event.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_state.dart';
import 'package:gp/features/professionals/presentation/pages/filter_page.dart';
import 'package:gp/features/professionals/presentation/pages/professional_detail_page.dart';
import 'package:gp/features/professionals/presentation/widgets/professional_card.dart';
import 'package:gp/injection_container.dart';

class CategoryProfessionalsPage extends StatefulWidget {
  final ServiceCategory category;

  const CategoryProfessionalsPage({super.key, required this.category});

  @override
  State<CategoryProfessionalsPage> createState() => _CategoryProfessionalsPageState();
}

class _CategoryProfessionalsPageState extends State<CategoryProfessionalsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Professional> _filteredList = [];

  @override
  void initState() {
    super.initState();
    context.read<ProfessionalsBloc>().add(LoadProfessionalsByCategory(widget.category));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query, List<Professional> all) {
    setState(() {
      _filteredList = query.isEmpty
          ? all
          : all.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<ProfessionalsBloc, ProfessionalsState>(
        listener: (context, state) {
          if (state is ProfessionalsLoaded) {
            setState(() => _filteredList = state.professionals);
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
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
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
              onPressed: () => context.read<ProfessionalsBloc>().add(LoadProfessionalsByCategory(widget.category)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
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
                            onChanged: (q) => _onSearch(q, state.professionals),
                            decoration: InputDecoration(
                              hintText: 'Search',
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
                // Filter button
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ProfessionalsBloc>(),
                          child: FilterPage(category: widget.category),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.primaryDark, size: 22),
                  ),
                ),
              ],
            ),
          ),
          // ── Professionals list ───────────────────────────────────
          Expanded(
            child: _filteredList.isEmpty
                ? Center(child: Text('No professionals found', style: AppTextStyles.bodyMedium))
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
                                create: (_) => sl<ProfessionalsBloc>(), // fresh bloc instance
                                child: ProfessionalDetailPage(professionalId: professional.id),
                              ),
                            ),
                          );
                        },
                        onFavoriteTap: () {
                          context.read<ProfessionalsBloc>().add(ToggleFavoriteEvent(professional.id));
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

// ─── Header ───────────────────────────────────────────────────────────────────

class _CategoryHeader extends StatelessWidget {
  final ServiceCategory category;

  const _CategoryHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, bottom: 28, left: 20, right: 20),
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
          // Category icon
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Center(
              child: SvgPicture.asset(
                category.iconAsset,
                width: 42,
                height: 42,
                colorFilter: const ColorFilter.mode(AppColors.primaryOrange, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            category.displayName,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            category.description,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

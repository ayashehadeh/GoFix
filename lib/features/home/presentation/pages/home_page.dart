import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gofix_bottom_nav_bar.dart';
import '../../../../injection_container.dart';
import '../../../professionals/domain/entities/service_category.dart';
import '../../../professionals/presentation/bloc/professionals_bloc.dart';
import '../../../professionals/presentation/pages/category_professionals_page.dart';
import '../../domain/entities/category_entity.dart';
import '../bloc/home_bloc.dart';
import '../widgets/category_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeLoadRequested());
  }

  void _onCategoryTap(CategoryEntity category) {
    // Map category name to ServiceCategory enum
    final serviceCategory = ServiceCategory.values.firstWhere(
      (e) => e.displayName == category.name,
      orElse: () => ServiceCategory.plumbing,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<ProfessionalsBloc>(),
          child: CategoryProfessionalsPage(category: serviceCategory),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Column(
            children: [
              _HomeHeader(
                locationName: state is HomeLoaded ? state.locationName : '...',
                isLoadingLocation: state is HomeLoading,
                onSearchTap: () {
                  // TODO: Navigate to search page
                },
                onNotificationTap: () {
                  // TODO: Navigate to notifications page
                },
              ),
              Expanded(child: _buildBody(state)),
            ],
          );
        },
      ),
      bottomNavigationBar: GoFixBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
      ),
    );
  }

  Widget _buildBody(HomeState state) {
    if (state is HomeLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryOrange),
      );
    }

    if (state is HomeError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(state.message, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<HomeBloc>().add(HomeLoadRequested()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (state is HomeLoaded) {
      return RefreshIndicator(
        color: AppColors.primaryOrange,
        onRefresh: () async {
          context.read<HomeBloc>().add(HomeRefreshRequested());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Categories', style: AppTextStyles.sectionTitle),
              ),
              const SizedBox(height: 16),
              _CategoriesGrid(
                categories: state.categories,
                onCategoryTap: _onCategoryTap,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final String locationName;
  final bool isLoadingLocation;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;

  const _HomeHeader({
    required this.locationName,
    required this.isLoadingLocation,
    required this.onSearchTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Location + notification row ───────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/home_screen/location_on.svg',
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryOrange,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Location', style: AppTextStyles.locationLabel),
                      isLoadingLocation
                          ? const SizedBox(
                              width: 120,
                              height: 16,
                              child: LinearProgressIndicator(
                                color: AppColors.primaryOrange,
                                backgroundColor: Colors.white24,
                              ),
                            )
                          : Text(locationName,
                              style: AppTextStyles.locationValue),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: onNotificationTap,
                child: SvgPicture.asset(
                  'assets/home_screen/notifications.svg',
                  width: 32,
                  height: 32,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Search bar ───────────────────────────────────────────
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/home_screen/search.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryDark,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Search', style: AppTextStyles.searchHint),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Categories Grid ──────────────────────────────────────────────────────────

class _CategoriesGrid extends StatelessWidget {
  final List<CategoryEntity> categories;
  final ValueChanged<CategoryEntity> onCategoryTap;

  const _CategoriesGrid({
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          childAspectRatio: 0.75,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return CategoryCard(
            category: categories[index],
            onTap: () => onCategoryTap(categories[index]),
          );
        },
      ),
    );
  }
}

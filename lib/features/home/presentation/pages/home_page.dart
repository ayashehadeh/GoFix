import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gp/core/utils/professional_nav_mixin.dart';
import 'package:gp/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gofix_bottom_nav_bar.dart';
import '../../../../injection_container.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_event.dart';
import '../../../notifications/presentation/bloc/notifications_state.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../professionals/domain/entities/service_category.dart';
import '../../../professionals/presentation/bloc/professionals_bloc.dart';
import '../../../professionals/presentation/pages/category_professionals_page.dart';
import '../../domain/entities/category_entity.dart';
import '../bloc/home_bloc.dart';
import '../widgets/category_card.dart';
import 'package:gp/features/search/presentation/bloc/search_bloc.dart';
import 'package:gp/features/search/presentation/pages/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver, ProfessionalNavMixin<HomePage> {
  final int _currentNavIndex = 0;
  late final NotificationsBloc _notificationsBloc;

  @override
  void initState() {
    super.initState();
    initProfessionalNav();
    final currentState = context.read<HomeBloc>().state;
    if (currentState is! HomeLoaded) {
      context.read<HomeBloc>().add(HomeLoadRequested());
    }
    _notificationsBloc = sl<NotificationsBloc>()..add(LoadNotifications());
  }

  @override
  void dispose() {
    _notificationsBloc.close();
    disposeProfessionalNav();
    super.dispose();
  }

  void _onCategoryTap(CategoryEntity category) {
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

  void _onNotificationTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _notificationsBloc,
          child: const NotificationsPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _notificationsBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Column(
              children: [
                BlocBuilder<NotificationsBloc, NotificationsState>(
                  builder: (context, notifState) {
                    final hasUnread = notifState is NotificationsLoaded && notifState.unreadCount > 0;
                    return _HomeHeader(
                      locationName: state is HomeLoaded ? state.locationName : '...',
                      isLoadingLocation: state is HomeLoading,
                      hasUnread: hasUnread,
                      onSearchTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => sl<SearchBloc>(),
                            child: const SearchPage(),
                          ),
                        ),
                      ),
                      onNotificationTap: _onNotificationTap,
                    );
                  },
                ),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
        bottomNavigationBar: GoFixBottomNavBar(
          currentIndex: _currentNavIndex,
          showDashboard: isProfessional,
          onTap: (index) {
            if (index == 0) return;
            if (index == 1) Navigator.pushNamedAndRemoveUntil(context, '/bookings', (route) => false);
            if (index == 2) Navigator.pushNamedAndRemoveUntil(context, '/profile', (route) => false);
            if (index == 3) Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
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
              onPressed: () => context.read<HomeBloc>().add(HomeLoadRequested()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(AppLocalizations.of(context)!.retry, style: const TextStyle(color: Colors.white)),
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
                child: Text(AppLocalizations.of(context)!.categories, style: AppTextStyles.sectionTitle),
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
  final bool hasUnread;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;

  const _HomeHeader({
    required this.locationName,
    required this.isLoadingLocation,
    required this.hasUnread,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/home_screen/location_on.svg',
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(AppColors.primaryOrange, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.location, style: AppTextStyles.locationLabel),
                      isLoadingLocation
                          ? const SizedBox(
                              width: 120,
                              height: 16,
                              child: LinearProgressIndicator(
                                color: AppColors.primaryOrange,
                                backgroundColor: Colors.white24,
                              ),
                            )
                          : Text(locationName, style: AppTextStyles.locationValue),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: onNotificationTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SvgPicture.asset(
                      'assets/home_screen/notifications.svg',
                      width: 32,
                      height: 32,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    if (hasUnread)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryDark, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                    colorFilter: const ColorFilter.mode(AppColors.primaryDark, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context)!.search, style: AppTextStyles.searchHint),
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
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          childAspectRatio: MediaQuery.of(context).size.width < 360 ? 0.65 : 0.75,
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

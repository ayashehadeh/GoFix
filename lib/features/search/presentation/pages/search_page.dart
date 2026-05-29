import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/l10n/area_name_l10n.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_bloc.dart';
import 'package:gp/features/professionals/presentation/pages/category_professionals_page.dart';
import 'package:gp/features/professionals/presentation/pages/professional_detail_page.dart';
import 'package:gp/features/search/domain/repositories/search_repository.dart';
import 'package:gp/injection_container.dart' as di;
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/area_result_tile.dart';
import '../widgets/search_professional_card.dart';
import '../widgets/service_result_tile.dart';
import 'area_professionals_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(LoadRecentSearches());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) =>
      context.read<SearchBloc>().add(SearchQueryChanged(value));

  void _onClear() {
    _controller.clear();
    context.read<SearchBloc>().add(SearchCleared());
    _focus.requestFocus();
  }

  void _onRecentTapped(String query) {
    _controller.text = query;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    context.read<SearchBloc>().add(RecentSearchTapped(query));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchBloc, SearchState>(
      listenWhen: (previous, current) =>
          current is AreaProfessionalsLoading &&
          previous is! AreaProfessionalsLoading &&
          previous is! AreaProfessionalsLoaded,
      listener: (context, state) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<SearchBloc>(),
              child: const AreaProfessionalsPage(),
            ),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFCFC),
        body: Column(
          children: [
            _SearchHeader(
              controller: _controller,
              focus: _focus,
              onChanged: _onChanged,
              onClear: _onClear,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: _SearchBody(
                controller: _controller,
                onRecentTapped: _onRecentTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onBack;

  const _SearchHeader({
    required this.controller,
    required this.focus,
    required this.onChanged,
    required this.onClear,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 18,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search,
                      color: Color(0xFF888888), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focus,
                      onChanged: onChanged,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF222222)),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            'Search professionals, services or areas',
                        hintStyle: TextStyle(
                            fontSize: 13, color: Color(0xFF999999)),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      if (controller.text.isEmpty) return const SizedBox();
                      return GestureDetector(
                        onTap: onClear,
                        child: const Icon(Icons.close,
                            color: Color(0xFF999999), size: 18),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _SearchBody extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onRecentTapped;

  const _SearchBody({
    required this.controller,
    required this.onRecentTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        // ── Empty field — show recent searches ─────────────────────────────
        if (state is SearchInitial) {
          return _RecentSearchesView(
            recentSearches: state.recentSearchObjects,
            onTap: onRecentTapped,
            onDelete: (id) =>
                context.read<SearchBloc>().add(RecentSearchDeleted(id)),
            onClearAll: () =>
                context.read<SearchBloc>().add(RecentSearchesCleared()),
          );
        }

        // ── Typing / loading ───────────────────────────────────────────────
        if (state is SearchTyping || state is SearchLoading) {
          final query = state is SearchTyping
              ? state.query
              : (state as SearchLoading).query;
          return Column(
            children: [
              if (state is SearchLoading)
                const LinearProgressIndicator(
                  color: AppColors.primaryOrange,
                  backgroundColor: Color(0xFFE0E0E0),
                  minHeight: 2,
                ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search,
                          size: 52, color: AppColors.divider),
                      const SizedBox(height: 16),
                      Text(
                        'Searching "$query"…',
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        // ── Error ──────────────────────────────────────────────────────────
        if (state is SearchError) {
          return Center(
            child: Text(state.message,
                style:
                    const TextStyle(color: AppColors.textSecondary)),
          );
        }

        // ── Results ────────────────────────────────────────────────────────
        if (state is SearchLoaded) {
          final results = state.results;
          if (results.isEmpty) {
            return _NoResults(query: results.query);
          }
          return _ResultsList(results: results);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Recent searches view ─────────────────────────────────────────────────────

class _RecentSearchesView extends StatelessWidget {
  final List<RecentSearch> recentSearches;
  final ValueChanged<String> onTap;    // passes query string
  final ValueChanged<String> onDelete; // passes server id
  final VoidCallback onClearAll;

  const _RecentSearchesView({
    required this.recentSearches,
    required this.onTap,
    required this.onDelete,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 52, color: AppColors.divider),
            SizedBox(height: 16),
            Text(
              'Search professionals, services or areas',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.recentSearches.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888888),
                letterSpacing: 0.8,
              ),
            ),
            GestureDetector(
              onTap: onClearAll,
              child: Text(
                AppLocalizations.of(context)!.clearAll,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...recentSearches.map(
          (item) => _RecentSearchRow(
            query: item.query,
            onTap: () => onTap(item.query),
            onDelete: () => onDelete(item.id),
          ),
        ),
      ],
    );
  }
}

class _RecentSearchRow extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RecentSearchRow({
    required this.query,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.history,
                size: 18, color: Color(0xFFAAAAAA)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                query,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF333333)),
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(Icons.close,
                    size: 16, color: Color(0xFFCCCCCC)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── No results ───────────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off,
              size: 52, color: AppColors.divider),
          const SizedBox(height: 16),
          Text(
            'No results for "$query"',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Results list ─────────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  final results;
  const _ResultsList({required this.results});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Services — shown first so service searches surface the right result immediately
        if (results.services.isNotEmpty) ...[
          _SectionHeader(label: 'Services', count: results.services.length),
          const SizedBox(height: 10),
          ...results.services.map(
            (service) => ServiceResultTile(
              service: service,
              query: results.query,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => di.sl<ProfessionalsBloc>(),
                    child: CategoryProfessionalsPage(
                      category: service.category,
                      serviceId: service.serviceId,
                      serviceName: service.serviceName,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Professionals
        if (results.professionals.isNotEmpty) ...[
          _SectionHeader(label: 'Professionals', count: results.professionals.length),
          const SizedBox(height: 10),
          ...results.professionals.map(
            (pro) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SearchProfessionalCard(
                professional: pro,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => di.sl<ProfessionalsBloc>(),
                      child: ProfessionalDetailPage(
                          professionalId: pro.id, id: pro.id),
                    ),
                  ),
                ),
                onFavoriteTap: () {},
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Areas
        if (results.areas.isNotEmpty) ...[
          _SectionHeader(label: 'Areas', count: results.areas.length),
          const SizedBox(height: 10),
          ...results.areas.map(
            (area) => AreaResultTile(
              area: area,
              query: results.query,
              onTap: () => context.read<SearchBloc>().add(
                    AreaSelected(
                      areaId: area.id,
                      areaName: localizeAreaName(area.name, l10n, nameAr: area.nameAr),
                      city: localizeCityName(area.city, l10n, nameAr: area.cityNameAr),
                      proCount: area.proCount,
                    ),
                  ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF888888),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryOrange,
            ),
          ),
        ),
      ],
    );
  }
}
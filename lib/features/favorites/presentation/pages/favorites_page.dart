import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_bloc.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/features/professionals/presentation/pages/professional_detail_page.dart';
import 'package:gp/injection_container.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/favorites_bloc.dart';
import '../../domain/entities/favorite_entity.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(const LoadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryDark),
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primaryOrange),
            );
          }
          if (state is FavoritesError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: AppColors.textSecondary)),
            );
          }
          if (state is FavoritesLoaded) {
            if (state.favorites.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)!.noFavoritesYet,
                    style: const TextStyle(color: AppColors.textSecondary)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final prof = state.favorites[index];
                return _FavoriteCard(
                  item: prof,
                  onRemove: () => context
                      .read<FavoritesBloc>()
                      .add(RemoveFavoriteEvent(prof.id)),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteEntity item;
  final VoidCallback onRemove;
  const _FavoriteCard({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
        return GestureDetector(                          // ADD THIS
      onTap: () => Navigator.push(                  // ADD THIS
        context,                                    // ADD THIS
        MaterialPageRoute(                          // ADD THIS
          builder: (_) => BlocProvider(             // ADD THIS
            create: (_) => sl<ProfessionalsBloc>(), // ADD THIS
child: ProfessionalDetailPage(id: item.id, professionalId: item.id),          ),                                        // ADD THIS
        ),                                          // ADD THIS
      ),                                            // ADD THIS
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFE0E8F0),
            child: Icon(Icons.person, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.settings,
                        color: AppColors.primaryOrange, size: 14),
                    const SizedBox(width: 4),
                    Text(item.role,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: AppColors.primaryOrange, size: 14),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.of(context)!.yearsExperience(item.yearsExperience),
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite,
                color: AppColors.primaryOrange),
            onPressed: onRemove,
          ),
        ],
      ),
    ));
  }
}

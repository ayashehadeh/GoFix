import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/favorites/favorites_cache.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/get_professionals_by_category.dart';
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/get_professional_by_id.dart';
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/get_my_profile.dart';
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/get_service_areas_by_professional.dart';
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/toggle_favorite.dart';
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/filter_professionals.dart';
import 'package:gp/features/professionals/domain/usecases/review_usecases/get_reviews_by_professional.dart';
import 'package:gp/features/professionals/domain/usecases/review_usecases/add_review.dart';
import 'package:gp/features/professionals/domain/usecases/review_usecases/edit_review.dart';
import 'package:gp/features/professionals/domain/usecases/review_usecases/delete_review.dart';
import 'professionals_event.dart';
import 'professionals_state.dart';

class ProfessionalsBloc extends Bloc<ProfessionalsEvent, ProfessionalsState> {
  final GetProfessionalsByCategory getProfessionalsByCategory;
  final GetProfessionalById getProfessionalById;
  final GetMyProfile getMyProfile;
  final GetServiceAreasByProfessional getServiceAreasByProfessional;
  final GetReviewsByProfessional getReviewsByProfessional;
  final ToggleFavorite toggleFavorite;
  final FilterProfessionals filterProfessionals;
  final AddReview addReview;
  final EditReview editReview;
  final DeleteReview deleteReview;

  ProfessionalsBloc({
    required this.getProfessionalsByCategory,
    required this.getProfessionalById,
    required this.getMyProfile,
    required this.getServiceAreasByProfessional,
    required this.getReviewsByProfessional,
    required this.toggleFavorite,
    required this.filterProfessionals,
    required this.addReview,
    required this.editReview,
    required this.deleteReview,
  }) : super(ProfessionalsInitial()) {
    on<LoadMyProfile>(_onLoadMyProfile);
    on<LoadProfessionalsByCategory>(_onLoadByCategory);
    on<LoadProfessionalDetail>(_onLoadDetail);
    on<LoadReviews>(_onLoadReviews);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<ApplyFilters>(_onApplyFilters);
    on<AddReviewEvent>(_onAddReview);
    on<EditReviewEvent>(_onEditReview);
    on<DeleteReviewEvent>(_onDeleteReview);
  }

  Future<void> _onLoadMyProfile(
    LoadMyProfile event,
    Emitter<ProfessionalsState> emit,
  ) async {
    emit(ProfessionalsLoading());
    final result = await getMyProfile();
    await result.fold(
      (failure) async => emit(ProfessionalsError(failure.message)),
      (professional) async {
        Professional professionalWithAreas = professional;
        try {
          final areasResult = await getServiceAreasByProfessional(professional.id)
              .timeout(const Duration(seconds: 4));
          areasResult.fold(
            (_) => null,
            (areas) {
              if (areas.isNotEmpty) {
                professionalWithAreas = professional.copyWith(serviceAreas: areas);
              }
            },
          );
        } catch (_) {}
        final reviewsResult = await getReviewsByProfessional(professional.id);
        reviewsResult.fold(
          (failure) => emit(ProfessionalsError(failure.message)),
          (reviews) => emit(ProfessionalDetailLoaded(
            professional: professionalWithAreas,
            reviews: reviews,
          )),
        );
      },
    );
  }

  Future<void> _onLoadByCategory(
    LoadProfessionalsByCategory event,
    Emitter<ProfessionalsState> emit,
  ) async {
    emit(ProfessionalsLoading());
    final result = await getProfessionalsByCategory(event.category);
    result.fold(
      (failure) => emit(ProfessionalsError(failure.message)),
      (professionals) {
        for (final p in professionals) {
          FavoritesCache.instance.set(p.id, p.isFavorite);
        }
        emit(ProfessionalsLoaded(
          professionals: professionals,
          category: event.category,
        ));
      },
    );
  }

  Future<void> _onLoadDetail(
    LoadProfessionalDetail event,
    Emitter<ProfessionalsState> emit,
  ) async {
    emit(ProfessionalsLoading());
    final profResult = await getProfessionalById(event.professionalId);
    await profResult.fold(
      (failure) async => emit(ProfessionalsError(failure.message)),
      (professional) async {
        Professional professionalWithAreas = professional;
        try {
          final areasResult = await getServiceAreasByProfessional(event.professionalId)
              .timeout(const Duration(seconds: 4));
          areasResult.fold(
            (_) => null,
            (areas) {
              if (areas.isNotEmpty) {
                professionalWithAreas = professional.copyWith(serviceAreas: areas);
              }
            },
          );
        } catch (_) {
          // endpoint unavailable — show profile without service areas
        }

        final reviewsResult = await getReviewsByProfessional(event.professionalId);
        reviewsResult.fold(
          (failure) => emit(ProfessionalsError(failure.message)),
          (reviews) {
            FavoritesCache.instance.set(professionalWithAreas.id, professionalWithAreas.isFavorite);
            emit(ProfessionalDetailLoaded(
              professional: professionalWithAreas,
              reviews: reviews,
            ));
          },
        );
      },
    );
  }

  Future<void> _onLoadReviews(
    LoadReviews event,
    Emitter<ProfessionalsState> emit,
  ) async {
    if (state is ProfessionalDetailLoaded) {
      final current = state as ProfessionalDetailLoaded;
      emit(ReviewsLoading(current.professional));
      final result = await getReviewsByProfessional(event.professionalId);
      result.fold(
        (failure) => emit(ProfessionalsError(failure.message)),
        (reviews) => emit(ProfessionalDetailLoaded(
          professional: current.professional,
          reviews: reviews,
        )),
      );
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<ProfessionalsState> emit,
  ) async {
    FavoritesCache.instance.toggle(event.professionalId);
    if (state is ProfessionalsLoaded) {
      final current = state as ProfessionalsLoaded;
      final updated = current.professionals.map((p) {
        if (p.id == event.professionalId) {
          return p.copyWith(isFavorite: !p.isFavorite);
        }
        return p;
      }).toList();
      emit(ProfessionalsLoaded(
        professionals: updated,
        category: current.category,
      ));
      final result = await toggleFavorite(event.professionalId);
      result.fold(
        (failure) {
          FavoritesCache.instance.toggle(event.professionalId); // revert
          emit(ProfessionalsLoaded(
            professionals: current.professionals,
            category: current.category,
          ));
        },
        (_) => null,
      );
    } else if (state is ProfessionalDetailLoaded) {
      final current = state as ProfessionalDetailLoaded;
      final updated = current.professional.copyWith(
        isFavorite: !current.professional.isFavorite,
      );
      emit(ProfessionalDetailLoaded(
        professional: updated,
        reviews: current.reviews,
      ));
      final result = await toggleFavorite(event.professionalId);
      result.fold(
        (failure) {
          FavoritesCache.instance.toggle(event.professionalId); // revert
          emit(ProfessionalDetailLoaded(
            professional: current.professional,
            reviews: current.reviews,
          ));
        },
        (_) => null,
      );
    } else {
      // toggled from a context with no bloc state (e.g. booking page)
      final result = await toggleFavorite(event.professionalId);
      result.fold(
        (failure) => FavoritesCache.instance.toggle(event.professionalId), // revert
        (_) => null,
      );
    }
  }

  Future<void> _onApplyFilters(
    ApplyFilters event,
    Emitter<ProfessionalsState> emit,
  ) async {
    emit(ProfessionalsLoading());
    final result = await filterProfessionals(
      category: event.category,
      minExperienceYears: event.minExperienceYears,
      maxDistanceKm: event.maxDistanceKm,
      minRating: event.minRating,
    );
    result.fold(
      (failure) => emit(ProfessionalsError(failure.message)),
      (professionals) => emit(ProfessionalsLoaded(
        professionals: professionals,
        category: event.category,
      )),
    );
  }

  Future<void> _onAddReview(
    AddReviewEvent event,
    Emitter<ProfessionalsState> emit,
  ) async {
    if (state is ProfessionalDetailLoaded) {
      final current = state as ProfessionalDetailLoaded;
      final result = await addReview(
        professionalId: event.professionalId,
        bookingId: event.bookingId,
        rating: event.rating,
        comment: event.comment,
      );
      result.fold(
        (failure) => emit(ProfessionalsError(failure.message)),
        (review) => emit(ReviewActionSuccess(
          professional: current.professional,
          reviews: [review, ...current.reviews],
          message: 'Review added successfully',
        )),
      );
    }
  }

  Future<void> _onEditReview(
    EditReviewEvent event,
    Emitter<ProfessionalsState> emit,
  ) async {
    if (state is ProfessionalDetailLoaded) {
      final current = state as ProfessionalDetailLoaded;
      final result = await editReview(
        reviewId: event.reviewId,
        rating: event.rating,
        comment: event.comment,
      );
      result.fold(
        (failure) => emit(ProfessionalsError(failure.message)),
        (updated) {
          final updatedReviews = current.reviews.map((r) {
            return r.id == event.reviewId ? updated : r;
          }).toList();
          emit(ReviewActionSuccess(
            professional: current.professional,
            reviews: updatedReviews,
            message: 'Review updated successfully',
          ));
        },
      );
    }
  }

  Future<void> _onDeleteReview(
    DeleteReviewEvent event,
    Emitter<ProfessionalsState> emit,
  ) async {
    if (state is ProfessionalDetailLoaded) {
      final current = state as ProfessionalDetailLoaded;
      final result = await deleteReview(event.reviewId);
      result.fold(
        (failure) => emit(ProfessionalsError(failure.message)),
        (_) {
          final updatedReviews =
              current.reviews.where((r) => r.id != event.reviewId).toList();
          emit(ReviewActionSuccess(
            professional: current.professional,
            reviews: updatedReviews,
            message: 'Review deleted successfully',
          ));
        },
      );
    }
  }
}

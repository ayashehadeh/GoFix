import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import '../entities/featured_banner_entity.dart';
import '../repositories/home_repository.dart';

class GetFeaturedBannersUseCase {
  final HomeRepository repository;

  GetFeaturedBannersUseCase(this.repository);

  Future<Either<Failure, List<FeaturedBannerEntity>>> call() =>
      repository.getFeaturedBanners();
}

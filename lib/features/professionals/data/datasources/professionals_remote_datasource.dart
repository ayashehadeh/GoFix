import 'package:dio/dio.dart';
import 'package:gp/features/professionals/data/models/professional_model.dart';
import 'package:gp/features/professionals/data/models/review_model.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/professionals/domain/entities/working_hours.dart';
import 'package:gp/features/professionals/domain/entities/service_offered.dart';
import 'package:gp/features/professionals/domain/entities/certification.dart';

abstract class ProfessionalsRemoteDataSource {
//10
  Future<List<ProfessionalModel>> getProfessionalsByCategory(ServiceCategory category);
  Future<ProfessionalModel> getProfessionalById(String id);
  Future<List<ProfessionalModel>> getFavorites();
  Future<void> toggleFavorite(String professionalId);
  Future<List<ProfessionalModel>> searchProfessionals(String query);
  Future<List<ProfessionalModel>> filterProfessionals({
    required ServiceCategory category,
    int? minExperienceYears,
    double? maxDistanceKm,
    double? minRating,
  });
  Future<List<ReviewModel>> getReviewsByProfessional(String professionalId);
  Future<ReviewModel> addReview({
    required String professionalId,
    required String bookingId,
    required double rating,
    required String comment,
  });
  Future<ReviewModel> editReview({required String reviewId, required double rating, required String comment});
  Future<void> deleteReview(String reviewId);
}

class ProfessionalsRemoteDataSourceImpl implements ProfessionalsRemoteDataSource {
  final Dio dio;

  ProfessionalsRemoteDataSourceImpl({required this.dio});

  // ── Professionals ────────────────────────────────────────────────

  @override
  Future<List<ProfessionalModel>> getProfessionalsByCategory(ServiceCategory category) async {
    // TODO: Replace with real endpoint
    // final response = await dio.get('/professionals', queryParameters: {'category': category.name});
    // return (response.data as List).map((e) => ProfessionalModel.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 600));
    return _mockProfessionals.where((p) => p.category == category).toList();
  }

  @override
  Future<ProfessionalModel> getProfessionalById(String id) async {
    // TODO: Replace with real endpoint
    // final response = await dio.get('/professionals/$id');
    // return ProfessionalModel.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 400));
    return _mockProfessionals.firstWhere((p) => p.id == id);
  }

  @override
  Future<List<ProfessionalModel>> getFavorites() async {
    // TODO: Replace with real endpoint
    // final response = await dio.get('/professionals/favorites');
    // return (response.data as List).map((e) => ProfessionalModel.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 400));
    return _mockProfessionals.where((p) => p.isFavorite).toList();
  }

  @override
  Future<void> toggleFavorite(String professionalId) async {
    // TODO: Replace with real endpoint
    // await dio.post('/professionals/$professionalId/favorite');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<List<ProfessionalModel>> searchProfessionals(String query) async {
    // TODO: Replace with real endpoint
    // final response = await dio.get('/professionals/search', queryParameters: {'q': query});
    // return (response.data as List).map((e) => ProfessionalModel.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 500));
    final q = query.toLowerCase();
    return _mockProfessionals
        .where((p) => p.name.toLowerCase().contains(q) || p.category.displayName.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<ProfessionalModel>> filterProfessionals({
    required ServiceCategory category,
    int? minExperienceYears,
    double? maxDistanceKm,
    double? minRating,
  }) async {
    // TODO: Replace with real endpoint
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockProfessionals.where((p) {
      if (p.category != category) return false;
      if (minExperienceYears != null && p.experienceYears < minExperienceYears) return false;
      if (maxDistanceKm != null && p.distanceKm > maxDistanceKm) return false;
      if (minRating != null && p.rating < minRating) return false;
      return true;
    }).toList();
  }

  // ── Reviews ──────────────────────────────────────────────────────

  @override
  Future<List<ReviewModel>> getReviewsByProfessional(String professionalId) async {
    // TODO: Replace with real endpoint
    // final response = await dio.get('/professionals/$professionalId/reviews');
    // return (response.data as List).map((e) => ReviewModel.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 400));
    return _mockReviews.where((r) => r.professionalId == professionalId).toList();
  }

  @override
  Future<ReviewModel> addReview({
    required String professionalId,
    required String bookingId,
    required double rating,
    required String comment,
  }) async {
    // TODO: Replace with real endpoint
    // final response = await dio.post('/reviews', data: {...});
    // return ReviewModel.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 400));
    return ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      professionalId: professionalId,
      bookingId: bookingId,
      reviewerId: 'current_user_id',
      reviewerName: 'Hazim Amir',
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<ReviewModel> editReview({required String reviewId, required double rating, required String comment}) async {
    // TODO: Replace with real endpoint
    // final response = await dio.put('/reviews/$reviewId', data: {...});
    // return ReviewModel.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 400));
    final existing = _mockReviews.firstWhere((r) => r.id == reviewId);
    return ReviewModel(
      id: existing.id,
      professionalId: existing.professionalId,
      bookingId: existing.bookingId,
      reviewerId: existing.reviewerId,
      reviewerName: existing.reviewerName,
      reviewerImageUrl: existing.reviewerImageUrl,
      rating: rating,
      comment: comment,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    // TODO: Replace with real endpoint
    // await dio.delete('/reviews/$reviewId');
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

// ── Mock Data ─────────────────────────────────────────────────────────────────

final _mockProfessionals = <ProfessionalModel>[
  ProfessionalModel(
    id: '1',
    name: 'Ahmad Khalil',
    category: ServiceCategory.plumbing,
    rating: 4.0,
    reviewCount: 52,
    ratingBreakdown: {5: 35, 4: 10, 3: 5, 2: 1, 1: 1},
    experienceYears: 2,
    distanceKm: 1.0,
    isFavorite: false,
    profileImageUrl: null,
    phone: '+962791234567',
    email: 'ahmad.khalil@email.com',
    bio: 'Experienced plumber with 2 years of expertise in residential plumbing.',
    serviceAreas: ['Sweifieh', 'Khalda', 'Al Rabiah', 'Um Uthaina'],
    workingHours: const WorkingHours(
      schedules: [
        DaySchedule(day: 'Sunday - Thursday', openTime: '8:00 AM', closeTime: '8:00 PM'),
        DaySchedule(day: 'Saturday', openTime: '9:00 AM', closeTime: '6:00 PM'),
      ],
    ),
    services: const [
      ServiceOffered(name: 'Pipe Installation', minPrice: 30, maxPrice: 40),
      ServiceOffered(name: 'Leak Repairs', minPrice: 25, maxPrice: 35),
      ServiceOffered(name: 'Water Heater Service', minPrice: 40, maxPrice: 60),
      ServiceOffered(name: 'Drain Cleaning', minPrice: 25, maxPrice: 30),
      ServiceOffered(name: 'Bathroom Fixtures', minPrice: 35, maxPrice: 50),
    ],
    certifications: const [
      Certification(name: 'Licensed Plumber', issuedBy: 'Jordan Plumbing Association', issuedYear: 2018),
      Certification(name: 'Water Systems Specialist', issuedBy: 'Technical Institute', issuedYear: 2020),
    ],
    isVerified: true,
    isIdentityVerified: true,
  ),
  ProfessionalModel(
    id: '2',
    name: 'Mohammed Hassan',
    category: ServiceCategory.plumbing,
    rating: 5.0,
    reviewCount: 120,
    ratingBreakdown: {5: 100, 4: 15, 3: 3, 2: 1, 1: 1},
    experienceYears: 10,
    distanceKm: 1.0,
    isFavorite: true,
    profileImageUrl: null,
    phone: '+962792345678',
    email: 'mohammed.hassan@email.com',
    bio: 'Master plumber with 10 years of expertise in residential and commercial plumbing.',
    serviceAreas: ['Sweifieh', 'Khalda', 'AlJubaiha'],
    workingHours: const WorkingHours(
      schedules: [DaySchedule(day: 'Sunday - Thursday', openTime: '8:00 AM', closeTime: '8:00 PM')],
    ),
    services: const [
      ServiceOffered(name: 'Pipe Installation', minPrice: 35, maxPrice: 50),
      ServiceOffered(name: 'Leak Repairs', minPrice: 30, maxPrice: 40),
    ],
    certifications: const [
      Certification(name: 'Licensed Plumber', issuedBy: 'Jordan Plumbing Association', issuedYear: 2015),
    ],
    isVerified: true,
    isIdentityVerified: true,
  ),
  ProfessionalModel(
    id: '3',
    name: 'Youssef Saeed',
    category: ServiceCategory.plumbing,
    rating: 3.0,
    reviewCount: 20,
    ratingBreakdown: {5: 5, 4: 5, 3: 7, 2: 2, 1: 1},
    experienceYears: 1,
    distanceKm: 0.1,
    isFavorite: false,
    profileImageUrl: null,
    phone: '+962793456789',
    email: 'youssef.saeed@email.com',
    bio: 'Junior plumber with 1 year of experience.',
    serviceAreas: ['AlJubaiha', 'Khalda'],
    workingHours: const WorkingHours(
      schedules: [DaySchedule(day: 'Sunday - Friday', openTime: '9:00 AM', closeTime: '6:00 PM')],
    ),
    services: const [
      ServiceOffered(name: 'Leak Repairs', minPrice: 20, maxPrice: 30),
      ServiceOffered(name: 'Drain Cleaning', minPrice: 20, maxPrice: 25),
    ],
    certifications: const [],
    isVerified: false,
    isIdentityVerified: true,
  ),
  ProfessionalModel(
    id: '4',
    name: 'Ali Emad',
    category: ServiceCategory.plumbing,
    rating: 5.0,
    reviewCount: 89,
    ratingBreakdown: {5: 80, 4: 6, 3: 2, 2: 1, 1: 0},
    experienceYears: 10,
    distanceKm: 1.0,
    isFavorite: true,
    profileImageUrl: null,
    phone: '+962794567890',
    email: 'ali.emad@email.com',
    bio: 'Senior plumber with 10 years of experience specializing in emergency repairs.',
    serviceAreas: ['Sweifieh', 'Khalda', 'Al Rabiah', 'Um Uthaina', 'AlJubaiha'],
    workingHours: const WorkingHours(
      schedules: [DaySchedule(day: 'Sunday - Saturday', openTime: '7:00 AM', closeTime: '10:00 PM')],
    ),
    services: const [
      ServiceOffered(name: 'Pipe Installation', minPrice: 40, maxPrice: 55),
      ServiceOffered(name: 'Leak Repairs', minPrice: 30, maxPrice: 45),
      ServiceOffered(name: 'Water Heater Service', minPrice: 50, maxPrice: 70),
    ],
    certifications: const [
      Certification(name: 'Licensed Plumber', issuedBy: 'Jordan Plumbing Association', issuedYear: 2014),
    ],
    isVerified: true,
    isIdentityVerified: true,
  ),
  // ── Electrical ───────────────────────────────────────────────────
  ProfessionalModel(
    id: '5',
    name: 'Ahmad Khalil',
    category: ServiceCategory.electricalWork,
    rating: 4.0,
    reviewCount: 30,
    ratingBreakdown: {5: 18, 4: 8, 3: 3, 2: 1, 1: 0},
    experienceYears: 2,
    distanceKm: 1.0,
    isFavorite: false,
    profileImageUrl: null,
    phone: '+962791234567',
    email: 'ahmad.khalil@email.com',
    bio: 'Electrician with 2 years of experience in residential wiring.',
    serviceAreas: ['Sweifieh', 'Khalda'],
    workingHours: const WorkingHours(
      schedules: [DaySchedule(day: 'Sunday - Thursday', openTime: '8:00 AM', closeTime: '6:00 PM')],
    ),
    services: const [
      ServiceOffered(name: 'Wiring Installation', minPrice: 40, maxPrice: 60),
      ServiceOffered(name: 'Circuit Repair', minPrice: 30, maxPrice: 50),
    ],
    certifications: const [],
    isVerified: true,
    isIdentityVerified: true,
  ),
  ProfessionalModel(
    id: '6',
    name: 'Mohammed Hassan',
    category: ServiceCategory.electricalWork,
    rating: 5.0,
    reviewCount: 95,
    ratingBreakdown: {5: 80, 4: 10, 3: 3, 2: 1, 1: 1},
    experienceYears: 10,
    distanceKm: 1.0,
    isFavorite: true,
    profileImageUrl: null,
    phone: '+962792345678',
    email: 'mohammed.hassan@email.com',
    bio: 'Senior electrician with 10 years of experience.',
    serviceAreas: ['Sweifieh', 'Khalda', 'AlJubaiha'],
    workingHours: const WorkingHours(
      schedules: [DaySchedule(day: 'Sunday - Thursday', openTime: '8:00 AM', closeTime: '8:00 PM')],
    ),
    services: const [
      ServiceOffered(name: 'Wiring Installation', minPrice: 50, maxPrice: 80),
      ServiceOffered(name: 'Light Fixture Installation', minPrice: 25, maxPrice: 40),
    ],
    certifications: const [
      Certification(name: 'Licensed Electrician', issuedBy: 'Jordan Electricians Association', issuedYear: 2016),
    ],
    isVerified: true,
    isIdentityVerified: true,
  ),
  ProfessionalModel(
    id: '7',
    name: 'Youssef Saeed',
    category: ServiceCategory.electricalWork,
    rating: 3.0,
    reviewCount: 15,
    ratingBreakdown: {5: 3, 4: 4, 3: 5, 2: 2, 1: 1},
    experienceYears: 1,
    distanceKm: 0.1,
    isFavorite: false,
    profileImageUrl: null,
    phone: '+962793456789',
    email: 'youssef.saeed@email.com',
    bio: 'Junior electrician with 1 year of experience.',
    serviceAreas: ['AlJubaiha'],
    workingHours: const WorkingHours(
      schedules: [DaySchedule(day: 'Sunday - Friday', openTime: '9:00 AM', closeTime: '5:00 PM')],
    ),
    services: const [ServiceOffered(name: 'Light Fixture Installation', minPrice: 20, maxPrice: 30)],
    certifications: const [],
    isVerified: false,
    isIdentityVerified: true,
  ),
  ProfessionalModel(
    id: '8',
    name: 'Ali Emad',
    category: ServiceCategory.electricalWork,
    rating: 5.0,
    reviewCount: 70,
    ratingBreakdown: {5: 60, 4: 7, 3: 2, 2: 1, 1: 0},
    experienceYears: 10,
    distanceKm: 1.0,
    isFavorite: true,
    profileImageUrl: null,
    phone: '+962794567890',
    email: 'ali.emad@email.com',
    bio: 'Expert electrician with 10 years of experience.',
    serviceAreas: ['Sweifieh', 'Khalda', 'Al Rabiah'],
    workingHours: const WorkingHours(
      schedules: [DaySchedule(day: 'Sunday - Saturday', openTime: '7:00 AM', closeTime: '9:00 PM')],
    ),
    services: const [
      ServiceOffered(name: 'Wiring Installation', minPrice: 60, maxPrice: 90),
      ServiceOffered(name: 'Circuit Repair', minPrice: 40, maxPrice: 60),
    ],
    certifications: const [
      Certification(name: 'Licensed Electrician', issuedBy: 'Jordan Electricians Association', issuedYear: 2014),
    ],
    isVerified: true,
    isIdentityVerified: true,
  ),
];

final _mockReviews = <ReviewModel>[
  ReviewModel(
    id: 'r1',
    professionalId: '1',
    bookingId: 'b1',
    reviewerId: 'u1',
    reviewerName: 'Sarah Mohammed',
    rating: 5.0,
    comment:
        'Excellent service! Ahmad fixed our kitchen sink leak quickly and professionally. Very clean work and fair pricing.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
  ),
  ReviewModel(
    id: 'r2',
    professionalId: '1',
    bookingId: 'b2',
    reviewerId: 'u2',
    reviewerName: 'Khaled Ali',
    rating: 5.0,
    comment: 'Highly recommend! He installed our new water heater and explained everything clearly. Very professional.',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  ReviewModel(
    id: 'r3',
    professionalId: '1',
    bookingId: 'b3',
    reviewerId: 'u3',
    reviewerName: 'Lina Hassan',
    rating: 4.0,
    comment: 'Good service overall. Fixed the leak but took a bit longer than expected.',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
];

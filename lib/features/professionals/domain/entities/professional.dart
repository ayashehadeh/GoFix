import 'package:equatable/equatable.dart';
import 'service_category.dart';
import 'service_offered.dart';
import 'certification.dart';
import 'working_hours.dart';

class Professional extends Equatable {
  final String id;
  final String name;
  final ServiceCategory category;
  final double rating;
  final int reviewCount;
  final Map<int, int> ratingBreakdown; // {5: 40, 4: 8, 3: 3, 2: 1, 1: 0}
  final int experienceYears;
  final double distanceKm;
  final bool isFavorite;
  final String? profileImageUrl;
  final String phone;
  final String email;
  final String bio;
  final List<String> serviceAreas;
  final WorkingHours workingHours;
  final List<ServiceOffered> services;
  final List<Certification> certifications;
  final bool isVerified;
  final bool isIdentityVerified;

  const Professional({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.ratingBreakdown,
    required this.experienceYears,
    required this.distanceKm,
    required this.isFavorite,
    this.profileImageUrl,
    required this.phone,
    required this.email,
    required this.bio,
    required this.serviceAreas,
    required this.workingHours,
    required this.services,
    required this.certifications,
    required this.isVerified,
    required this.isIdentityVerified,
  });

  /// e.g. "8 Years Exp."
  String get experienceLabel => '$experienceYears Years Exp.';

  /// e.g. "1.2 KM Away"
  String get distanceLabel => '${distanceKm.toStringAsFixed(1)} KM Away';

  /// Returns a copy with updated isFavorite
  Professional copyWith({bool? isFavorite}) {
    return Professional(
      id: id,
      name: name,
      category: category,
      rating: rating,
      reviewCount: reviewCount,
      ratingBreakdown: ratingBreakdown,
      experienceYears: experienceYears,
      distanceKm: distanceKm,
      isFavorite: isFavorite ?? this.isFavorite,
      profileImageUrl: profileImageUrl,
      phone: phone,
      email: email,
      bio: bio,
      serviceAreas: serviceAreas,
      workingHours: workingHours,
      services: services,
      certifications: certifications,
      isVerified: isVerified,
      isIdentityVerified: isIdentityVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        rating,
        reviewCount,
        ratingBreakdown,
        experienceYears,
        distanceKm,
        isFavorite,
        profileImageUrl,
        phone,
        email,
        bio,
        serviceAreas,
        workingHours,
        services,
        certifications,
        isVerified,
        isIdentityVerified,
      ];
}

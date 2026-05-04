import 'package:equatable/equatable.dart';
import 'service_category.dart';
import 'service_area.dart';
import 'service_offered.dart';
import 'professional_document.dart';
import 'working_hours.dart';

class Professional extends Equatable {
  final String id;
  final String name;
  final ServiceCategory category;
  final double rating;
  final int reviewCount;
  final Map<int, int> ratingBreakdown;
  final int experienceYears;
  final double? distanceKm;
  final bool isFavorite;
  final String? profileImageUrl;
  final String phone;
  final String email;
  final String bio;
  final List<ServiceArea> serviceAreas;
  final WorkingHours workingHours;
  final List<ServiceOffered> services;
  final List<ProfessionalDocument> documents;
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
    this.distanceKm,
    required this.isFavorite,
    this.profileImageUrl,
    required this.phone,
    required this.email,
    required this.bio,
    required this.serviceAreas,
    required this.workingHours,
    required this.services,
    required this.documents,
    required this.isVerified,
    required this.isIdentityVerified,
  });

  /// Only certification type documents
  List<ProfessionalDocument> get certifications =>
      documents.where((d) => d.isCertification).toList();

  /// e.g. "8 Years Exp."
  String get experienceLabel => '$experienceYears Years Exp.';

  /// e.g. "1.2 KM Away"
  String get distanceLabel => distanceKm != null
      ? '${distanceKm!.toStringAsFixed(1)} KM Away'
      : '-- KM Away';

  /// Convenience: just the area names as strings (for display)
  List<String> get serviceAreaNames => serviceAreas.map((a) => a.name).toList();

  Professional copyWith({
    bool? isFavorite,
    double? distanceKm,
    List<ServiceArea>? serviceAreas,
    String? profileImageUrl,
  }) {
    return Professional(
      id: id,
      name: name,
      category: category,
      rating: rating,
      reviewCount: reviewCount,
      ratingBreakdown: ratingBreakdown,
      experienceYears: experienceYears,
      distanceKm: distanceKm ?? this.distanceKm,
      isFavorite: isFavorite ?? this.isFavorite,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phone: phone,
      email: email,
      bio: bio,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      workingHours: workingHours,
      services: services,
      documents: documents,
      isVerified: isVerified,
      isIdentityVerified: isIdentityVerified,
    );
  }

  @override
  List<Object?> get props => [
        id, name, category, rating, reviewCount, ratingBreakdown,
        experienceYears, distanceKm, isFavorite, profileImageUrl,
        phone, email, bio, serviceAreas, workingHours, services,
        documents, isVerified, isIdentityVerified,
      ];
}
import 'package:gp/features/professionals/domain/entities/certification.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/professionals/domain/entities/service_offered.dart';
import 'package:gp/features/professionals/domain/entities/working_hours.dart';

class ProfessionalModel extends Professional {
  const ProfessionalModel({
    required super.id,
    required super.name,
    required super.category,
    required super.rating,
    required super.reviewCount,
    required super.ratingBreakdown,
    required super.experienceYears,
    required super.distanceKm,
    required super.isFavorite,
    super.profileImageUrl,
    required super.phone,
    required super.email,
    required super.bio,
    required super.serviceAreas,
    required super.workingHours,
    required super.services,
    required super.certifications,
    required super.isVerified,
    required super.isIdentityVerified,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: ServiceCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ServiceCategory.plumbing,
      ),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'] as int,
      ratingBreakdown: (json['rating_breakdown'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(int.parse(k), v as int),
      ),
      experienceYears: json['experience_years'] as int,
      distanceKm: (json['distance_km'] as num).toDouble(),
      isFavorite: json['is_favorite'] as bool? ?? false,
      profileImageUrl: json['profile_image_url'] as String?,
      phone: json['phone'] as String,
      email: json['email'] as String,
      bio: json['bio'] as String,
      serviceAreas: List<String>.from(json['service_areas'] as List),
      workingHours: WorkingHours(
        schedules: (json['working_hours'] as List)
            .map((e) => DaySchedule(
                  day: e['day'] as String,
                  openTime: e['open_time'] as String,
                  closeTime: e['close_time'] as String,
                ))
            .toList(),
      ),
      services: (json['services'] as List)
          .map((e) => ServiceOffered(
                name: e['name'] as String,
                minPrice: (e['min_price'] as num).toDouble(),
                maxPrice: e['max_price'] != null
                    ? (e['max_price'] as num).toDouble()
                    : null,
              ))
          .toList(),
      certifications: (json['certifications'] as List)
          .map((e) => Certification(
                name: e['name'] as String,
                issuedBy: e['issued_by'] as String,
                issuedYear: e['issued_year'] as int,
              ))
          .toList(),
      isVerified: json['is_verified'] as bool? ?? false,
      isIdentityVerified: json['is_identity_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'rating': rating,
        'review_count': reviewCount,
        'rating_breakdown':
            ratingBreakdown.map((k, v) => MapEntry(k.toString(), v)),
        'experience_years': experienceYears,
        'distance_km': distanceKm,
        'is_favorite': isFavorite,
        'profile_image_url': profileImageUrl,
        'phone': phone,
        'email': email,
        'bio': bio,
        'service_areas': serviceAreas,
        'working_hours': workingHours.schedules
            .map((e) => {
                  'day': e.day,
                  'open_time': e.openTime,
                  'close_time': e.closeTime,
                })
            .toList(),
        'services': services
            .map((e) => {
                  'name': e.name,
                  'min_price': e.minPrice,
                  'max_price': e.maxPrice,
                })
            .toList(),
        'certifications': certifications
            .map((e) => {
                  'name': e.name,
                  'issued_by': e.issuedBy,
                  'issued_year': e.issuedYear,
                })
            .toList(),
        'is_verified': isVerified,
        'is_identity_verified': isIdentityVerified,
      };
}

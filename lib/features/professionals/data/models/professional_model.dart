import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/professional_document.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/professionals/domain/entities/service_offered.dart';
import 'package:gp/features/professionals/domain/entities/working_hours.dart';
import 'package:gp/features/professionals/data/models/service_area_model.dart';

class ProfessionalModel extends Professional {
  const ProfessionalModel({
    required super.id,
    required super.name,
    required super.category,
    required super.rating,
    required super.reviewCount,
    required super.ratingBreakdown,
    required super.experienceYears,
    super.distanceKm,
    required super.isFavorite,
    super.profileImageUrl,
    required super.phone,
    required super.email,
    required super.bio,
    required super.serviceAreas,
    required super.workingHours,
    required super.services,
    required super.documents,
    required super.isVerified,
    required super.isIdentityVerified,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: ServiceCategory.values.firstWhere(
        (e) =>
            e.displayName.toLowerCase() ==
            (json['category'] as String).toLowerCase(),
        orElse: () => ServiceCategory.plumbing,
      ),
      rating: (json['rating'] as num).toDouble(),
      reviewCount:
          (json['reviewCount'] as num? ?? json['review_count'] as num? ?? 0)
              .toInt(),
      ratingBreakdown: (json['ratingBreakdown'] as Map<String, dynamic>? ??
              json['rating_breakdown'] as Map<String, dynamic>? ??
              {})
          .map((k, v) => MapEntry(int.parse(k), (v as num).toInt())),
      experienceYears: (json['experienceYears'] as num? ??
              json['experience_years'] as num? ??
              0)
          .toInt(),
      distanceKm: (json['distanceKm'] ?? json['distance_km']) != null
          ? ((json['distanceKm'] ?? json['distance_km']) as num).toDouble()
          : null,
      isFavorite:
          json['isFavorite'] as bool? ?? json['is_favorite'] as bool? ?? false,
      profileImageUrl: json['profileImageUrl'] as String? ??
          json['profile_image_url'] as String?,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      bio: json['bio'] as String? ?? '',

      // ── Service areas — backend now returns objects with id/name/cityId ──
      serviceAreas: ((json['serviceAreas'] as List?) ??
              (json['service_areas'] as List?) ??
              [])
          .map((e) => e is String
              // legacy plain-string fallback — safe to remove once backend is live
              ? ServiceAreaModel(id: 0, name: e, cityId: 0)
              : ServiceAreaModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      workingHours: WorkingHours(
        schedules: ((json['workingHours'] as List? ??
                json['working_hours'] as List? ??
                []))
            .map((e) => DaySchedule(
                  day: e['day'] as String,
                  openTime: e['openTime'] as String? ??
                      e['open_time'] as String? ??
                      '',
                  closeTime: e['closeTime'] as String? ??
                      e['close_time'] as String? ??
                      '',
                ))
            .toList(),
      ),
      services: ((json['services'] as List?) ?? [])
          .map((e) => ServiceOffered(
                serviceId: (e['serviceId'] ?? e['service_id']) is num
                    ? (e['serviceId'] ?? e['service_id'])?.toInt()
                    : int.tryParse('${e['serviceId'] ?? e['service_id']}'),
                name: e['name'] as String,
                minPrice: (e['minPrice'] as num? ?? e['min_price'] as num? ?? 0)
                    .toDouble(),
                maxPrice: (e['maxPrice'] ?? e['max_price']) != null
                    ? ((e['maxPrice'] ?? e['max_price']) as num).toDouble()
                    : null,
              ))
          .toList(),
      // backend returns "certifications" key with only certification-type docs
      documents: ((json['certifications'] as List?) ?? [])
          .map((e) => ProfessionalDocument(
                id: (e['id'] as num).toInt(),
                documentType: e['documentType'] as String? ??
                    e['document_type'] as String? ??
                    'certification',
                name: e['name'] as String? ?? '',
                issuedBy: e['issuedBy'] as String? ?? e['issued_by'] as String?,
                issuedYear: (e['issuedYear'] ?? e['issued_year']) != null
                    ? ((e['issuedYear'] ?? e['issued_year']) as num).toInt()
                    : null,
                fileUrl:
                    e['fileUrl'] as String? ?? e['file_url'] as String? ?? '',
                fileName: e['fileName'] as String? ?? e['file_name'] as String?,
                fileType: e['fileType'] as String? ?? e['file_type'] as String?,
                uploadedAt: DateTime.parse(e['uploadedAt'] as String? ??
                    e['uploaded_at'] as String? ??
                    DateTime.now().toIso8601String()),
              ))
          .toList(),
      isVerified:
          json['isVerified'] as bool? ?? json['is_verified'] as bool? ?? false,
      isIdentityVerified: json['isIdentityVerified'] as bool? ??
          json['is_identity_verified'] as bool? ??
          false,
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
        // ── Serialize as objects, not plain strings ──
        'service_areas': serviceAreas
            .map((a) => (a as ServiceAreaModel).toJson())
            .toList(),
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
        'certifications': documents
            .map((e) => {
                  'id': e.id,
                  'document_type': e.documentType,
                  'name': e.name,
                  'issued_by': e.issuedBy,
                  'issued_year': e.issuedYear,
                  'file_url': e.fileUrl,
                  'file_name': e.fileName,
                  'file_type': e.fileType,
                  'uploaded_at': e.uploadedAt.toIso8601String(),
                })
            .toList(),
        'is_verified': isVerified,
        'is_identity_verified': isIdentityVerified,
      };
}
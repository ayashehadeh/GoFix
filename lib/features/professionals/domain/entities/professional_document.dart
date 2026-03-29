import 'package:equatable/equatable.dart';

// Document types:
// "certification"  → professional certificates, many allowed
// "identity"       → national ID, only one allowed
// "good_conduct"   → certificate of good conduct, only one allowed
class ProfessionalDocument extends Equatable {
  final int id;
  final String documentType;
  final String name;
  final String? issuedBy;
  final int? issuedYear;
  final String fileUrl;
  final String? fileName;
  final String? fileType;
  final DateTime uploadedAt;

  const ProfessionalDocument({
    required this.id,
    required this.documentType,
    required this.name,
    this.issuedBy,
    this.issuedYear,
    required this.fileUrl,
    this.fileName,
    this.fileType,
    required this.uploadedAt,
  });

  bool get isCertification => documentType == 'certification';
  bool get isIdentity => documentType == 'identity';
  bool get isGoodConduct => documentType == 'good_conduct';

  /// e.g. "Issued 2018" or empty if no year
  String get issuedLabel => issuedYear != null ? 'Issued $issuedYear' : '';

  /// Human readable document type label
  String get typeLabel {
    switch (documentType) {
      case 'certification':
        return 'Certification';
      case 'identity':
        return 'National ID';
      case 'good_conduct':
        return 'Good Conduct';
      default:
        return documentType;
    }
  }

  @override
  List<Object?> get props => [
        id,
        documentType,
        name,
        issuedBy,
        issuedYear,
        fileUrl,
        fileName,
        fileType,
        uploadedAt,
      ];
}
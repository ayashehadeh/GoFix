/// Document types accepted by the backend.
/// Backend expects exact strings: "identity", "certification", "good_conduct".
enum DocumentType {
  identity,
  certification,
  goodConduct;

  /// API string the backend expects.
  String get apiValue {
    switch (this) {
      case DocumentType.identity:
        return 'identity';
      case DocumentType.certification:
        return 'certification';
      case DocumentType.goodConduct:
        return 'good_conduct';
    }
  }
}

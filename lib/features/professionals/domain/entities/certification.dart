import 'package:equatable/equatable.dart';

class Certification extends Equatable {
  final String name;
  final String issuedBy;
  final int issuedYear;

  const Certification({
    required this.name,
    required this.issuedBy,
    required this.issuedYear,
  });

  /// e.g. "Issued 2018"
  String get issuedLabel => 'Issued $issuedYear';

  @override
  List<Object> get props => [name, issuedBy, issuedYear];
}

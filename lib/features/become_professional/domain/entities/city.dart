import 'package:equatable/equatable.dart';

class City extends Equatable {
  final int id;
  final String name;
  final String? nameAr;

  const City({required this.id, required this.name, this.nameAr});

  @override
  List<Object?> get props => [id, name, nameAr];
}

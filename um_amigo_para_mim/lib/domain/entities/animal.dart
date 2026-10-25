import 'package:equatable/equatable.dart';

/// A pet available for adoption in the MVP catalog.
class Animal extends Equatable {
  const Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.gender,
    required this.age,
    required this.image,
    required this.story,
    required this.behavior,
  });

  final String id;
  final String name;
  final String species;
  final String gender;
  final String age;
  final String image;
  final String story;
  final String behavior;

  @override
  List<Object?> get props => [
    id,
    name,
    species,
    gender,
    age,
    image,
    story,
    behavior,
  ];
}

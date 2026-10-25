import 'package:equatable/equatable.dart';

import '../../domain/entities/animal.dart';

enum AnimalStatus { initial, loading, success, failure }

class AnimalState extends Equatable {
  const AnimalState({
    this.status = AnimalStatus.initial,
    this.animals = const [],
    this.selectedAnimal,
    this.species,
    this.errorMessage,
  });

  final AnimalStatus status;
  final List<Animal> animals;
  final Animal? selectedAnimal;
  final String? species;
  final String? errorMessage;

  AnimalState copyWith({
    AnimalStatus? status,
    List<Animal>? animals,
    Animal? selectedAnimal,
    String? species,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AnimalState(
      status: status ?? this.status,
      animals: animals ?? this.animals,
      selectedAnimal: selectedAnimal ?? this.selectedAnimal,
      species: species ?? this.species,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    animals,
    selectedAnimal,
    species,
    errorMessage,
  ];
}

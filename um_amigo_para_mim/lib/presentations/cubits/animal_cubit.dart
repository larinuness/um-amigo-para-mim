import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/animal_use_case.dart';
import 'animal_state.dart';

export 'animal_state.dart';

class AnimalCubit extends Cubit<AnimalState> {
  AnimalCubit(this.useCase) : super(const AnimalState());

  final AnimalUseCase useCase;

  Future<void> loadBySpecies(String species) async {
    emit(
      state.copyWith(
        status: AnimalStatus.loading,
        species: species,
        clearError: true,
      ),
    );
    try {
      final animals = await useCase.getAnimalsBySpecies(species);
      emit(
        state.copyWith(
          status: AnimalStatus.success,
          animals: animals,
          species: species,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AnimalStatus.failure,
          species: species,
          errorMessage: _messageFor(error),
        ),
      );
    }
  }

  Future<void> loadAnimal(String id) async {
    emit(state.copyWith(status: AnimalStatus.loading, clearError: true));
    try {
      final animal = await useCase.getAnimalById(id);
      emit(
        state.copyWith(
          status: AnimalStatus.success,
          selectedAnimal: animal,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AnimalStatus.failure,
          errorMessage: _messageFor(error),
        ),
      );
    }
  }

  Future<void> loadAll() async {
    emit(state.copyWith(status: AnimalStatus.loading, clearError: true));
    try {
      final animals = await useCase.getAllAnimals();
      emit(
        state.copyWith(
          status: AnimalStatus.success,
          animals: animals,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AnimalStatus.failure,
          errorMessage: _messageFor(error),
        ),
      );
    }
  }

  Future<void> fetchAnimalsBySpecies(String species) => loadBySpecies(species);

  Future<void> fetchAnimalById(String id) => loadAnimal(id);

  Future<void> fetchAllAnimals() => loadAll();

  String _messageFor(Object error) {
    if (error is StateError) return error.message;
    return 'Não foi possível carregar os animais. Tente novamente.';
  }
}

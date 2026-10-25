import '../entities/animal.dart';
import '../repositories/animal_repository.dart';

class AnimalUseCase {
  const AnimalUseCase(this.repository);

  final AnimalRepository repository;

  Future<List<Animal>> getAnimalsBySpecies(String species) =>
      repository.getAnimalsBySpecies(species);

  Future<Animal> getAnimalById(String id) => repository.getAnimalById(id);

  Future<List<Animal>> getAllAnimals() => repository.getAllAnimals();
}

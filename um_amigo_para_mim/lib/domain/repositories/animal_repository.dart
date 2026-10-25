import '../entities/animal.dart';

abstract class AnimalRepository {
  Future<List<Animal>> getAnimalsBySpecies(String species);

  Future<Animal> getAnimalById(String id);

  Future<List<Animal>> getAllAnimals();
}

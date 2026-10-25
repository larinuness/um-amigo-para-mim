import '../entities/animal.dart';
import '../repositories/profile_repository.dart';

class ProfileUseCase {
  const ProfileUseCase(this.repository);

  final ProfileRepository repository;

  Future<List<String>> getFavoriteIds() => repository.getFavoriteIds();

  Future<void> toggleFavorite(String animalId) =>
      repository.toggleFavorite(animalId);

  Future<bool> isFavorite(String animalId) => repository.isFavorite(animalId);

  List<Animal> getFavoriteAnimals(
    List<Animal> animals,
    Iterable<String> favoriteIds,
  ) {
    final ids = favoriteIds.toSet();
    return animals.where((animal) => ids.contains(animal.id)).toList();
  }
}

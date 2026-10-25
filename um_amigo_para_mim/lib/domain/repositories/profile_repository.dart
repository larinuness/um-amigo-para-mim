abstract class ProfileRepository {
  Future<List<String>> getFavoriteIds();

  Future<void> toggleFavorite(String animalId);

  Future<bool> isFavorite(String animalId);
}

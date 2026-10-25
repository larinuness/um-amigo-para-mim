import '../../domain/repositories/profile_repository.dart';

/// Small synchronous-in-memory implementation used by widget previews/tests.
class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository([Set<String>? initialFavorites])
    : _favoriteIds = {...?initialFavorites};

  final Set<String> _favoriteIds;

  @override
  Future<List<String>> getFavoriteIds() async => _favoriteIds.toList();

  @override
  Future<void> toggleFavorite(String animalId) async {
    if (!_favoriteIds.add(animalId)) {
      _favoriteIds.remove(animalId);
    }
  }

  @override
  Future<bool> isFavorite(String animalId) async =>
      _favoriteIds.contains(animalId);
}

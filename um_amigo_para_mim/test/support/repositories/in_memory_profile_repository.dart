import 'package:um_amigo_para_mim/domain/repositories/profile_repository.dart';

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

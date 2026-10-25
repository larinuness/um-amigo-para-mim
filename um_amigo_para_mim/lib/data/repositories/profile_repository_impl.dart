import 'package:shared_preferences/shared_preferences.dart';

import '../../core/configs/app_config.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this.preferences);

  final SharedPreferences preferences;

  @override
  Future<List<String>> getFavoriteIds() async {
    return preferences.getStringList(AppConfig.favoriteAnimalIdsKey) ?? [];
  }

  @override
  Future<void> toggleFavorite(String animalId) async {
    final favorites = await getFavoriteIds();
    if (favorites.contains(animalId)) {
      favorites.remove(animalId);
    } else {
      favorites.add(animalId);
    }
    await preferences.setStringList(AppConfig.favoriteAnimalIdsKey, favorites);
  }

  @override
  Future<bool> isFavorite(String animalId) async {
    return (await getFavoriteIds()).contains(animalId);
  }
}

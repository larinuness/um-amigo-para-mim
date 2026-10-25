import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:um_amigo_para_mim/data/repositories/profile_repository_impl.dart';

void main() {
  test('persiste inclusão e remoção de favoritos', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = ProfileRepositoryImpl(preferences);

    await repository.toggleFavorite('dog-01');
    expect(await repository.getFavoriteIds(), ['dog-01']);
    expect(await repository.isFavorite('dog-01'), isTrue);

    await repository.toggleFavorite('dog-01');
    expect(await repository.getFavoriteIds(), isEmpty);
  });
}

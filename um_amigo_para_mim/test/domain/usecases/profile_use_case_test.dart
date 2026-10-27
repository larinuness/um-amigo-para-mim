import 'package:flutter_test/flutter_test.dart';
import 'package:um_amigo_para_mim/domain/entities/animal.dart';
import 'package:um_amigo_para_mim/domain/usecases/profile_use_case.dart';

import '../../support/repositories/in_memory_profile_repository.dart';

void main() {
  test('ProfileUseCase seleciona apenas os animais favoritos', () {
    const animals = [
      Animal(
        id: 'dog-01',
        name: 'Thor',
        species: 'dog',
        gender: 'male',
        age: '2 anos',
        image: '',
        story: '',
        behavior: '',
      ),
      Animal(
        id: 'cat-01',
        name: 'Nina',
        species: 'cat',
        gender: 'female',
        age: '2 anos',
        image: '',
        story: '',
        behavior: '',
      ),
    ];
    final useCase = ProfileUseCase(InMemoryProfileRepository());

    final favorites = useCase.getFavoriteAnimals(animals, const ['cat-01']);

    expect(favorites.single.name, 'Nina');
  });
}

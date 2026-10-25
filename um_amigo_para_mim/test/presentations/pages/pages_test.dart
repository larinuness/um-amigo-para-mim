import 'package:flutter_test/flutter_test.dart';

import 'package:um_amigo_para_mim/data/repositories/in_memory_profile_repository.dart';
import 'package:um_amigo_para_mim/domain/entities/animal.dart';
import 'package:um_amigo_para_mim/domain/repositories/animal_repository.dart';
import 'package:um_amigo_para_mim/main.dart';
import 'package:um_amigo_para_mim/core/configs/dependency_injection.dart';

class _FakeAnimalRepository implements AnimalRepository {
  final animals = const [
    Animal(
      id: 'dog-01',
      name: 'Thor',
      species: 'dog',
      gender: 'male',
      age: '2 anos',
      image: '',
      story: 'Thor espera uma família.',
      behavior: 'Brincalhão e dócil.',
    ),
    Animal(
      id: 'cat-01',
      name: 'Nina',
      species: 'cat',
      gender: 'female',
      age: '2 anos',
      image: '',
      story: 'Nina espera uma família.',
      behavior: 'Curiosa e carinhosa.',
    ),
  ];

  @override
  Future<List<Animal>> getAllAnimals() async => animals;

  @override
  Future<Animal> getAnimalById(String id) async =>
      animals.firstWhere((animal) => animal.id == id);

  @override
  Future<List<Animal>> getAnimalsBySpecies(String species) async =>
      animals.where((animal) => animal.species == species).toList();
}

void main() {
  AppDependencies dependencies() => DependencyInjection.createWith(
    animalRepository: _FakeAnimalRepository(),
    profileRepository: InMemoryProfileRepository(),
  );

  testWidgets('navega da seleção para a lista e para os detalhes', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp(dependencies: dependencies()));

    expect(find.text('Um amigo\npara mim'), findsOneWidget);
    expect(find.text('Cachorros'), findsOneWidget);
    await tester.tap(find.text('Cachorros'));
    await tester.pumpAndSettle();

    expect(find.text('Thor'), findsOneWidget);
    await tester.tap(find.text('Thor'));
    await tester.pumpAndSettle();

    expect(find.text('A história de Thor'), findsOneWidget);
    expect(find.text('Thor espera uma família.'), findsOneWidget);
  });

  testWidgets('favoritar no grid exibe o animal no perfil', (tester) async {
    await tester.pumpWidget(MyApp(dependencies: dependencies()));
    await tester.tap(find.text('Cachorros'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Adicionar aos favoritos'));
    await tester.pump();
    await tester.tap(find.byTooltip('Meus favoritos'));
    await tester.pumpAndSettle();

    expect(find.text('Thor'), findsOneWidget);
  });
}

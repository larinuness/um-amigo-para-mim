import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:um_amigo_para_mim/domain/entities/animal.dart';
import 'package:um_amigo_para_mim/domain/repositories/animal_repository.dart';
import 'package:um_amigo_para_mim/domain/usecases/animal_use_case.dart';
import 'package:um_amigo_para_mim/presentations/cubits/animal_cubit.dart';

const _animal = Animal(
  id: 'dog-01',
  name: 'Thor',
  species: 'dog',
  gender: 'male',
  age: '2 anos',
  image: '',
  story: 'Resgatado.',
  behavior: 'Docil.',
);

class _FakeAnimalRepository implements AnimalRepository {
  const _FakeAnimalRepository({this.shouldFail = false});

  final bool shouldFail;

  void _check() {
    if (shouldFail) throw Exception('failure');
  }

  @override
  Future<List<Animal>> getAllAnimals() async {
    _check();
    return const [_animal];
  }

  @override
  Future<Animal> getAnimalById(String id) async {
    _check();
    return _animal;
  }

  @override
  Future<List<Animal>> getAnimalsBySpecies(String species) async {
    _check();
    return const [_animal];
  }
}

void main() {
  blocTest<AnimalCubit, AnimalState>(
    'emits loading and success when loading by species',
    build: () => AnimalCubit(AnimalUseCase(const _FakeAnimalRepository())),
    act: (cubit) => cubit.loadBySpecies('dog'),
    expect: () => [
      isA<AnimalState>().having(
        (state) => state.status,
        'status',
        AnimalStatus.loading,
      ),
      isA<AnimalState>()
          .having((state) => state.status, 'status', AnimalStatus.success)
          .having((state) => state.animals, 'animals', const [_animal]),
    ],
  );

  blocTest<AnimalCubit, AnimalState>(
    'emits failure when the catalog fails',
    build: () => AnimalCubit(
      AnimalUseCase(const _FakeAnimalRepository(shouldFail: true)),
    ),
    act: (cubit) => cubit.loadBySpecies('dog'),
    expect: () => [
      isA<AnimalState>().having(
        (state) => state.status,
        'status',
        AnimalStatus.loading,
      ),
      isA<AnimalState>().having(
        (state) => state.status,
        'status',
        AnimalStatus.failure,
      ),
    ],
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:um_amigo_para_mim/data/models/animal_model.dart';

void main() {
  test('converte um animal a partir de JSON', () {
    final animal = AnimalModel.fromJson({
      'id': 'dog-01',
      'name': 'Thor',
      'species': 'dog',
      'gender': 'male',
      'age': '2 anos',
      'image': 'thor.jpg',
      'story': 'Resgatado.',
      'behavior': 'Dócil.',
    });

    expect(animal.id, 'dog-01');
    expect(animal.name, 'Thor');
    expect(animal.toJson()['species'], 'dog');
  });

  test('usa valores seguros quando campos opcionais não existem', () {
    final animal = AnimalModel.fromJson({'id': 10});

    expect(animal.id, '10');
    expect(animal.name, 'Sem nome');
    expect(animal.story, isEmpty);
  });
}

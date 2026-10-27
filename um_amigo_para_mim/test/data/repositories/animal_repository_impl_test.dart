import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:um_amigo_para_mim/data/repositories/animal_repository_impl.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  late _MockHttpClient client;
  late AnimalRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    client = _MockHttpClient();
    repository = AnimalRepositoryImpl(
      client: client,
      baseUrl: 'http://localhost:3000',
    );
  });

  test('loads animals from the API', () async {
    when(() => client.get(any())).thenAnswer(
      (_) async => http.Response(
        jsonEncode([
          {
            'id': 'dog-01',
            'name': 'Thor',
            'species': 'dog',
            'gender': 'male',
            'age': '2 anos',
            'image': '',
            'story': 'Resgatado.',
            'behavior': 'Docil.',
          },
        ]),
        200,
      ),
    );

    final animals = await repository.getAnimalsBySpecies('dog');
    expect(animals.single.name, 'Thor');
  });

  test('propagates the API error when it fails', () async {
    when(() => client.get(any())).thenThrow(Exception('API indisponivel'));

    expect(repository.getAnimalsBySpecies('cat'), throwsA(isA<Exception>()));
  });
}

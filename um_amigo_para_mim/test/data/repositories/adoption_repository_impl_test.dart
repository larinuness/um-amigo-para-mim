import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:um_amigo_para_mim/data/repositories/adoption_repository_impl.dart';
import 'package:um_amigo_para_mim/domain/entities/adoption_process.dart';

class _MockHttpClient extends Mock implements http.Client {}

Map<String, dynamic> processJson({
  String status = 'started',
  String animalId = 'dog-01',
}) {
  return {
    'id': 'profile-1__$animalId',
    'animalId': animalId,
    'profileId': 'profile-1',
    'status': status,
    'startedAt': '2026-10-26T12:00:00.000Z',
    'updatedAt': '2026-10-26T12:00:00.000Z',
  };
}

void main() {
  late _MockHttpClient client;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    client = _MockHttpClient();
  });

  test('carrega processos ativos da Mock API', () async {
    SharedPreferences.setMockInitialValues({
      'anonymous_profile_id': 'profile-1',
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = AdoptionRepositoryImpl(
      client: client,
      baseUrl: 'http://localhost:3000',
      preferences: preferences,
    );
    when(
      () => client.get(any()),
    ).thenAnswer((_) async => http.Response(jsonEncode([processJson()]), 200));

    final processes = await repository.getActiveProcesses();

    expect(processes.single.animalId, 'dog-01');
    expect(processes.single.status, AdoptionProcessStatus.started);
  });

  test('propaga o erro quando a Mock API falha', () async {
    SharedPreferences.setMockInitialValues({
      'anonymous_profile_id': 'profile-1',
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = AdoptionRepositoryImpl(
      client: client,
      baseUrl: 'http://localhost:3000',
      preferences: preferences,
    );
    when(() => client.get(any())).thenThrow(Exception('API indisponível'));

    expect(repository.getActiveProcesses(), throwsA(isA<Exception>()));
  });

  test('inicia e cancela processo pela Mock API', () async {
    SharedPreferences.setMockInitialValues({
      'anonymous_profile_id': 'profile-1',
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = AdoptionRepositoryImpl(
      client: client,
      baseUrl: 'http://localhost:3000',
      preferences: preferences,
    );
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response('[]', 200));
    when(
      () => client.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => http.Response(jsonEncode(processJson()), 201));
    when(
      () => client.patch(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer(
      (_) async =>
          http.Response(jsonEncode(processJson(status: 'cancelled')), 200),
    );

    final first = await repository.startProcess('dog-01');
    await repository.cancelProcess('dog-01');

    expect(first.isActive, isTrue);
  });
}

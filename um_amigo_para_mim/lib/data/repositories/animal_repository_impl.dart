import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';
import '../models/animal_model.dart';

class AnimalRepositoryImpl implements AnimalRepository {
  AnimalRepositoryImpl({
    required this.client,
    required this.baseUrl,
    this.timeout = const Duration(seconds: 5),
  });

  final http.Client client;
  final String baseUrl;
  final Duration timeout;

  Uri _endpoint(String path, [Map<String, String>? queryParameters]) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return Uri.parse(normalizedBase)
        .resolve(path)
        .replace(queryParameters: queryParameters);
  }

  @override
  Future<List<Animal>> getAnimalsBySpecies(String species) async {
    final response = await client
        .get(_endpoint('animals', {'species': species}))
        .timeout(timeout);
    _ensureSuccess(response);
    return _decodeList(response.body);
  }

  @override
  Future<Animal> getAnimalById(String id) async {
    final response = await client
        .get(_endpoint('animals/${Uri.encodeComponent(id)}'))
        .timeout(timeout);
    _ensureSuccess(response);
    return AnimalModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<List<Animal>> getAllAnimals() async {
    final response = await client.get(_endpoint('animals')).timeout(timeout);
    _ensureSuccess(response);
    return _decodeList(response.body);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'API respondeu com status ${response.statusCode}',
        response.request?.url,
      );
    }
  }

  List<AnimalModel> _decodeList(String body) {
    final decoded = jsonDecode(body) as List<dynamic>;
    return decoded
        .map((item) => AnimalModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

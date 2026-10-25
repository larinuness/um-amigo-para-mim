import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../core/configs/app_config.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';
import '../models/animal_model.dart';

class AnimalRepositoryImpl implements AnimalRepository {
  AnimalRepositoryImpl({
    required this.client,
    required this.baseUrl,
    AssetBundle? assetBundle,
    this.fallbackLoader,
    this.timeout = const Duration(seconds: 5),
  }) : assetBundle = assetBundle ?? rootBundle;

  final http.Client client;
  final String baseUrl;
  final AssetBundle assetBundle;
  final Future<String> Function()? fallbackLoader;
  final Duration timeout;

  Future<List<AnimalModel>>? _fallbackCache;

  Uri _endpoint(String path, [Map<String, String>? queryParameters]) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return Uri.parse(normalizedBase)
        .resolve(path)
        .replace(queryParameters: queryParameters);
  }

  @override
  Future<List<Animal>> getAnimalsBySpecies(String species) async {
    try {
      final response = await client
          .get(_endpoint('animals', {'species': species}))
          .timeout(timeout);
      _ensureSuccess(response);
      return _decodeList(response.body);
    } catch (_) {
      final animals = await _loadFallback();
      return animals
          .where(
            (animal) => animal.species.toLowerCase() == species.toLowerCase(),
          )
          .toList();
    }
  }

  @override
  Future<Animal> getAnimalById(String id) async {
    try {
      final response = await client
          .get(_endpoint('animals/${Uri.encodeComponent(id)}'))
          .timeout(timeout);
      _ensureSuccess(response);
      return AnimalModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (_) {
      final animals = await _loadFallback();
      return animals.firstWhere(
        (animal) => animal.id == id,
        orElse: () => throw StateError('Animal não encontrado: $id'),
      );
    }
  }

  @override
  Future<List<Animal>> getAllAnimals() async {
    try {
      final response = await client.get(_endpoint('animals')).timeout(timeout);
      _ensureSuccess(response);
      return _decodeList(response.body);
    } catch (_) {
      return _loadFallback();
    }
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

  Future<List<AnimalModel>> _loadFallback() {
    return _fallbackCache ??= _readFallback();
  }

  Future<List<AnimalModel>> _readFallback() async {
    final body =
        await (fallbackLoader?.call() ??
            assetBundle.loadString(AppConfig.fallbackAssetPath));
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final animals = decoded['animals'] as List<dynamic>;
    return animals
        .map((item) => AnimalModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

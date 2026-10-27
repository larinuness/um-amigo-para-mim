import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/configs/app_config.dart';
import '../../domain/entities/adoption_process.dart';
import '../../domain/repositories/adoption_repository.dart';
import '../models/adoption_process_model.dart';

class AdoptionRepositoryImpl implements AdoptionRepository {
  AdoptionRepositoryImpl({
    required this.client,
    required this.baseUrl,
    required this.preferences,
    this.timeout = const Duration(seconds: 5),
  });

  final http.Client client;
  final String baseUrl;
  final SharedPreferences preferences;
  final Duration timeout;

  Future<String>? _profileIdFuture;

  @override
  Future<List<AdoptionProcess>> getActiveProcesses() async {
    final profileId = await _getProfileId();
    final response = await client
        .get(
          _endpoint('adoptionProcesses', {
            'profileId': profileId,
            'status': 'started',
          }),
        )
        .timeout(timeout);
    _ensureSuccess(response);

    return _decodeList(response.body)
        .where((process) => process.profileId == profileId && process.isActive)
        .toList();
  }

  @override
  Future<AdoptionProcess> startProcess(String animalId) async {
    final profileId = await _getProfileId();
    final lookupResponse = await client
        .get(
          _endpoint('adoptionProcesses', {
            'profileId': profileId,
            'animalId': animalId,
          }),
        )
        .timeout(timeout);
    _ensureSuccess(lookupResponse);

    final existing = _decodeList(lookupResponse.body)
        .where(
          (process) =>
              process.profileId == profileId && process.animalId == animalId,
        )
        .toList();
    final activeProcess = existing
        .where((process) => process.isActive)
        .firstOrNull;
    if (activeProcess != null) return activeProcess;

    final now = DateTime.now().toUtc();
    final process = AdoptionProcessModel(
      id: _processId(profileId, animalId),
      animalId: animalId,
      profileId: profileId,
      status: AdoptionProcessStatus.started,
      startedAt: now,
      updatedAt: now,
    );
    final body = jsonEncode(process.toJson());

    if (existing.isNotEmpty) {
      final response = await client
          .patch(
            _endpoint(
              'adoptionProcesses/${Uri.encodeComponent(existing.first.id)}',
            ),
            headers: const {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(timeout);
      _ensureSuccess(response);
    } else {
      final response = await client
          .post(
            _endpoint('adoptionProcesses'),
            headers: const {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(timeout);
      _ensureSuccess(response);
    }

    return process;
  }

  @override
  Future<void> cancelProcess(String animalId) async {
    final profileId = await _getProfileId();
    final lookupResponse = await client
        .get(
          _endpoint('adoptionProcesses', {
            'profileId': profileId,
            'animalId': animalId,
          }),
        )
        .timeout(timeout);
    _ensureSuccess(lookupResponse);

    final activeProcess = _decodeList(lookupResponse.body)
        .where(
          (process) =>
              process.profileId == profileId &&
              process.animalId == animalId &&
              process.isActive,
        )
        .firstOrNull;
    if (activeProcess == null) return;

    final cancelled = AdoptionProcessModel.fromEntity(
      activeProcess.copyWith(
        status: AdoptionProcessStatus.cancelled,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    final response = await client
        .patch(
          _endpoint(
            'adoptionProcesses/${Uri.encodeComponent(activeProcess.id)}',
          ),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(cancelled.toJson()),
        )
        .timeout(timeout);
    _ensureSuccess(response);
  }

  Uri _endpoint(String path, [Map<String, String>? queryParameters]) {
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return Uri.parse(normalizedBase)
        .resolve(path)
        .replace(queryParameters: queryParameters);
  }

  Future<String> _getProfileId() {
    return _profileIdFuture ??= _createOrReadProfileId();
  }

  Future<String> _createOrReadProfileId() async {
    final stored = preferences.getString(AppConfig.anonymousProfileIdKey);
    if (stored != null && stored.isNotEmpty) return stored;

    final generated = 'profile-${DateTime.now().microsecondsSinceEpoch}';
    await preferences.setString(AppConfig.anonymousProfileIdKey, generated);
    return generated;
  }

  String _processId(String profileId, String animalId) =>
      '${profileId}__$animalId';

  List<AdoptionProcessModel> _decodeList(String body) {
    final decoded = jsonDecode(body) as List<dynamic>;
    return decoded
        .map(
          (item) => AdoptionProcessModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'API respondeu com status ${response.statusCode}',
        response.request?.url,
      );
    }
  }
}

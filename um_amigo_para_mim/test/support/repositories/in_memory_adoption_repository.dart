import 'package:um_amigo_para_mim/domain/entities/adoption_process.dart';
import 'package:um_amigo_para_mim/domain/repositories/adoption_repository.dart';

class InMemoryAdoptionRepository implements AdoptionRepository {
  InMemoryAdoptionRepository({this.profileId = 'test-profile'})
    : _processes = {};

  final String profileId;
  final Map<String, AdoptionProcess> _processes;

  @override
  Future<List<AdoptionProcess>> getActiveProcesses() async {
    return _processes.values.where((process) => process.isActive).toList();
  }

  @override
  Future<AdoptionProcess> startProcess(String animalId) async {
    final id = '${profileId}__$animalId';
    final existing = _processes[id];
    if (existing != null && existing.isActive) return existing;

    final now = DateTime.now().toUtc();
    final process = AdoptionProcess(
      id: id,
      animalId: animalId,
      profileId: profileId,
      status: AdoptionProcessStatus.started,
      startedAt: now,
      updatedAt: now,
    );
    _processes[id] = process;
    return process;
  }

  @override
  Future<void> cancelProcess(String animalId) async {
    final id = '${profileId}__$animalId';
    final existing = _processes[id];
    if (existing == null || !existing.isActive) return;
    _processes[id] = existing.copyWith(
      status: AdoptionProcessStatus.cancelled,
      updatedAt: DateTime.now().toUtc(),
    );
  }
}

import '../entities/adoption_process.dart';

abstract class AdoptionRepository {
  Future<List<AdoptionProcess>> getActiveProcesses();

  Future<AdoptionProcess> startProcess(String animalId);

  Future<void> cancelProcess(String animalId);
}

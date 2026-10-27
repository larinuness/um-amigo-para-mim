import '../entities/adoption_process.dart';
import '../repositories/adoption_repository.dart';

class AdoptionUseCase {
  const AdoptionUseCase(this.repository);

  final AdoptionRepository repository;

  Future<List<AdoptionProcess>> getActiveProcesses() =>
      repository.getActiveProcesses();

  Future<AdoptionProcess> startProcess(String animalId) =>
      repository.startProcess(animalId);

  Future<void> cancelProcess(String animalId) =>
      repository.cancelProcess(animalId);
}

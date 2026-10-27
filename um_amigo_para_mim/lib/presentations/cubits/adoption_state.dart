import 'package:equatable/equatable.dart';

import '../../domain/entities/adoption_process.dart';

enum AdoptionStatus { initial, loading, ready, failure }

class AdoptionState extends Equatable {
  const AdoptionState({
    this.status = AdoptionStatus.initial,
    this.processes = const {},
    this.errorMessage,
  });

  final AdoptionStatus status;
  final Map<String, AdoptionProcess> processes;
  final String? errorMessage;

  bool contains(String animalId) => processes.containsKey(animalId);

  AdoptionState copyWith({
    AdoptionStatus? status,
    Map<String, AdoptionProcess>? processes,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdoptionState(
      status: status ?? this.status,
      processes: processes ?? this.processes,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, processes, errorMessage];
}

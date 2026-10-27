import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/adoption_use_case.dart';
import 'adoption_state.dart';

export 'adoption_state.dart';

class AdoptionCubit extends Cubit<AdoptionState> {
  AdoptionCubit(this.useCase) : super(const AdoptionState());

  final AdoptionUseCase useCase;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: AdoptionStatus.loading,
        processes: const {},
        clearError: true,
      ),
    );
    try {
      final processes = await useCase.getActiveProcesses();
      emit(
        state.copyWith(
          status: AdoptionStatus.ready,
          processes: {
            for (final process in processes) process.animalId: process,
          },
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AdoptionStatus.failure,
          errorMessage: 'Não foi possível carregar seus processos de adoção.',
        ),
      );
    }
  }

  Future<void> startProcess(String animalId) async {
    if (state.contains(animalId)) return;

    try {
      final process = await useCase.startProcess(animalId);
      emit(
        state.copyWith(
          status: AdoptionStatus.ready,
          processes: {...state.processes, animalId: process},
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AdoptionStatus.failure,
          errorMessage: 'Não foi possível iniciar este processo.',
        ),
      );
    }
  }

  Future<void> cancelProcess(String animalId) async {
    if (!state.contains(animalId)) return;
    final previousProcesses = state.processes;

    try {
      await useCase.cancelProcess(animalId);
      final updatedProcesses = {...previousProcesses}..remove(animalId);
      emit(
        state.copyWith(
          status: AdoptionStatus.ready,
          processes: updatedProcesses,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AdoptionStatus.failure,
          processes: previousProcesses,
          errorMessage: 'Não foi possível cancelar este processo.',
        ),
      );
    }
  }

  bool isInProcess(String animalId) => state.contains(animalId);
}

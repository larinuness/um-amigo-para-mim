import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:um_amigo_para_mim/domain/usecases/adoption_use_case.dart';
import 'package:um_amigo_para_mim/presentations/cubits/adoption_cubit.dart';

import '../../support/repositories/in_memory_adoption_repository.dart';

void main() {
  blocTest<AdoptionCubit, AdoptionState>(
    'carrega, inicia e cancela um processo',
    build: () => AdoptionCubit(AdoptionUseCase(InMemoryAdoptionRepository())),
    act: (cubit) async {
      await cubit.load();
      await cubit.startProcess('dog-01');
      await cubit.cancelProcess('dog-01');
    },
    expect: () => [
      isA<AdoptionState>().having(
        (state) => state.status,
        'status',
        AdoptionStatus.loading,
      ),
      isA<AdoptionState>().having(
        (state) => state.status,
        'status',
        AdoptionStatus.ready,
      ),
      isA<AdoptionState>().having(
        (state) => state.contains('dog-01'),
        'contains dog-01',
        isTrue,
      ),
      isA<AdoptionState>().having(
        (state) => state.contains('dog-01'),
        'contains dog-01',
        isFalse,
      ),
    ],
  );
}

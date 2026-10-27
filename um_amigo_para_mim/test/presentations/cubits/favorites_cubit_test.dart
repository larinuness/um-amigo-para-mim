import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:um_amigo_para_mim/domain/usecases/profile_use_case.dart';
import 'package:um_amigo_para_mim/presentations/cubits/favorites_cubit.dart';

import '../../support/repositories/in_memory_profile_repository.dart';

void main() {
  blocTest<FavoritesCubit, FavoritesState>(
    'loads and toggles favorites',
    build: () => FavoritesCubit(ProfileUseCase(InMemoryProfileRepository())),
    act: (cubit) async {
      await cubit.load();
      await cubit.toggleFavorite('dog-01');
      await cubit.toggleFavorite('dog-01');
    },
    expect: () => [
      isA<FavoritesState>().having(
        (state) => state.status,
        'status',
        FavoritesStatus.loading,
      ),
      isA<FavoritesState>().having(
        (state) => state.status,
        'status',
        FavoritesStatus.ready,
      ),
      isA<FavoritesState>().having(
        (state) => state.favoriteIds,
        'favoriteIds',
        {'dog-01'},
      ),
      isA<FavoritesState>().having(
        (state) => state.favoriteIds,
        'favoriteIds',
        <String>{},
      ),
    ],
  );
}

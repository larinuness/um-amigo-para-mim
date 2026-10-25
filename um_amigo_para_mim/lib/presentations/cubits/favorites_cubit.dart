import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/profile_use_case.dart';
import 'favorites_state.dart';

export 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this.useCase) : super(const FavoritesState());

  final ProfileUseCase useCase;

  Future<void> load() async {
    emit(state.copyWith(status: FavoritesStatus.loading, clearError: true));
    try {
      final ids = await useCase.getFavoriteIds();
      emit(
        state.copyWith(
          status: FavoritesStatus.ready,
          favoriteIds: ids.toSet(),
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: FavoritesStatus.failure,
          errorMessage: 'Não foi possível carregar seus favoritos.',
        ),
      );
    }
  }

  Future<void> toggleFavorite(String animalId) async {
    final updatedIds = {...state.favoriteIds};
    if (!updatedIds.add(animalId)) {
      updatedIds.remove(animalId);
    }
    final previousIds = state.favoriteIds;
    emit(
      state.copyWith(
        status: FavoritesStatus.ready,
        favoriteIds: updatedIds,
        clearError: true,
      ),
    );

    try {
      await useCase.toggleFavorite(animalId);
    } catch (_) {
      emit(
        state.copyWith(
          status: FavoritesStatus.failure,
          favoriteIds: previousIds,
          errorMessage: 'Não foi possível salvar esta alteração.',
        ),
      );
    }
  }

  Future<void> toggle(String animalId) => toggleFavorite(animalId);

  Future<void> loadFavorites() => load();

  bool isFavorite(String animalId) => state.contains(animalId);
}

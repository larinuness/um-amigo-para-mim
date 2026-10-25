import 'package:equatable/equatable.dart';

enum FavoritesStatus { initial, loading, ready, failure }

class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favoriteIds = const {},
    this.errorMessage,
  });

  final FavoritesStatus status;
  final Set<String> favoriteIds;
  final String? errorMessage;

  bool contains(String id) => favoriteIds.contains(id);

  FavoritesState copyWith({
    FavoritesStatus? status,
    Set<String>? favoriteIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, favoriteIds, errorMessage];
}

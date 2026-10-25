import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/animal.dart';
import '../cubits/animal_cubit.dart';
import '../cubits/favorites_cubit.dart';
import '../widgets/animal_grid_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/loading_state_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnimalCubit>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus favoritos'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: BlocBuilder<AnimalCubit, AnimalState>(
        builder: (context, animalState) {
          if (animalState.status == AnimalStatus.loading &&
              animalState.animals.isEmpty) {
            return const LoadingStateWidget(
              message: 'Carregando seus amigos...',
            );
          }
          if (animalState.status == AnimalStatus.failure &&
              animalState.animals.isEmpty) {
            return ErrorStateWidget(
              message:
                  animalState.errorMessage ??
                  'Não foi possível carregar seus favoritos.',
              onRetry: () => context.read<AnimalCubit>().loadAll(),
            );
          }

          return BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, favoritesState) {
              final favorites = animalState.animals
                  .where((animal) => favoritesState.contains(animal.id))
                  .toList();
              if (favorites.isEmpty) return const EmptyStateWidget();
              return AnimalGridWidget(
                animals: favorites,
                favoriteIds: favoritesState.favoriteIds,
                onAnimalTap: (animal) => _openDetails(context, animal),
                onFavoriteToggle: (animal) =>
                    context.read<FavoritesCubit>().toggleFavorite(animal.id),
              );
            },
          );
        },
      ),
    );
  }

  void _openDetails(BuildContext context, Animal animal) {
    context.push('/animals/${animal.species}/${animal.id}');
  }
}

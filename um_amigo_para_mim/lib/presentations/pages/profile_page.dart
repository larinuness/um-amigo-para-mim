import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/animal.dart';
import '../cubits/adoption_cubit.dart';
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
      context.read<AdoptionCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meu perfil'),
          leading: BackButton(onPressed: () => context.pop()),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Curtidos'),
              Tab(text: 'Em processo'),
            ],
          ),
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
                    'Não foi possível carregar seu perfil.',
                onRetry: () => context.read<AnimalCubit>().loadAll(),
              );
            }

            return BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favoritesState) {
                return BlocBuilder<AdoptionCubit, AdoptionState>(
                  builder: (context, adoptionState) {
                    return TabBarView(
                      children: [
                        _buildFavoritesTab(
                          context,
                          animalState.animals,
                          favoritesState,
                        ),
                        _buildAdoptionTab(
                          context,
                          animalState.animals,
                          favoritesState,
                          adoptionState,
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFavoritesTab(
    BuildContext context,
    List<Animal> animals,
    FavoritesState favoritesState,
  ) {
    final favorites = animals
        .where((animal) => favoritesState.contains(animal.id))
        .toList();
    if (favorites.isEmpty) {
      return const EmptyStateWidget();
    }

    return _buildGrid(context, favorites, favoritesState.favoriteIds);
  }

  Widget _buildAdoptionTab(
    BuildContext context,
    List<Animal> animals,
    FavoritesState favoritesState,
    AdoptionState adoptionState,
  ) {
    if (adoptionState.status == AdoptionStatus.loading &&
        adoptionState.processes.isEmpty) {
      return const LoadingStateWidget(message: 'Carregando seus processos...');
    }
    if (adoptionState.status == AdoptionStatus.failure &&
        adoptionState.processes.isEmpty) {
      return ErrorStateWidget(
        message:
            adoptionState.errorMessage ??
            'Não foi possível carregar seus processos.',
        onRetry: () => context.read<AdoptionCubit>().load(),
      );
    }

    final inProcess = animals
        .where((animal) => adoptionState.contains(animal.id))
        .toList();
    if (inProcess.isEmpty) {
      return const EmptyStateWidget(
        title: 'Nenhum processo iniciado',
        message: 'Quando você iniciar uma adoção, o animal aparecerá aqui.',
        icon: Icons.assignment_outlined,
      );
    }

    return _buildGrid(context, inProcess, favoritesState.favoriteIds);
  }

  Widget _buildGrid(
    BuildContext context,
    List<Animal> animals,
    Set<String> favoriteIds,
  ) {
    return AnimalGridWidget(
      animals: animals,
      favoriteIds: favoriteIds,
      onAnimalTap: (animal) => _openDetails(context, animal),
      onFavoriteToggle: (animal) =>
          context.read<FavoritesCubit>().toggleFavorite(animal.id),
    );
  }

  void _openDetails(BuildContext context, Animal animal) {
    context.push('/animals/${animal.species}/${animal.id}');
  }
}

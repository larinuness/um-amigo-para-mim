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

class AnimalsPage extends StatefulWidget {
  const AnimalsPage({super.key, required this.species});

  final String species;

  @override
  State<AnimalsPage> createState() => _AnimalsPageState();
}

class _AnimalsPageState extends State<AnimalsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(covariant AnimalsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.species != widget.species) _load();
  }

  void _load() {
    if (mounted) context.read<AnimalCubit>().loadBySpecies(widget.species);
  }

  @override
  Widget build(BuildContext context) {
    final isDog = widget.species.toLowerCase() == 'dog';
    final title = isDog ? 'Cachorros' : 'Gatos';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            onPressed: () async {
              await context.push('/profile');
              _load();
            },
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Meus favoritos',
          ),
        ],
      ),
      body: BlocBuilder<AnimalCubit, AnimalState>(
        builder: (context, animalState) {
          if (animalState.status == AnimalStatus.loading &&
              animalState.animals.isEmpty) {
            return const LoadingStateWidget();
          }
          if (animalState.status == AnimalStatus.failure &&
              animalState.animals.isEmpty) {
            return ErrorStateWidget(
              message:
                  animalState.errorMessage ??
                  'Não foi possível carregar os animais.',
              onRetry: _load,
            );
          }
          if (animalState.animals.isEmpty) {
            return const EmptyStateWidget(
              title: 'Nenhum animal encontrado',
              message: 'Ainda estamos procurando novos amigos por aqui.',
              icon: Icons.search_off_rounded,
            );
          }

          return BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, favoritesState) {
              return AnimalGridWidget(
                animals: animalState.animals,
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
    context.push('/animals/${widget.species}/${animal.id}');
  }
}

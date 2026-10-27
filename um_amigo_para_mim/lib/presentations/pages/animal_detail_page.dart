import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/animal.dart';
import '../cubits/adoption_cubit.dart';
import '../cubits/animal_cubit.dart';
import '../cubits/favorites_cubit.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/favorite_button_widget.dart';
import '../widgets/loading_state_widget.dart';

class AnimalDetailPage extends StatefulWidget {
  const AnimalDetailPage({
    super.key,
    required this.species,
    required this.animalId,
  });

  final String species;
  final String animalId;

  @override
  State<AnimalDetailPage> createState() => _AnimalDetailPageState();
}

class _AnimalDetailPageState extends State<AnimalDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selected = context.read<AnimalCubit>().state.selectedAnimal;
      if (selected?.id != widget.animalId) {
        context.read<AnimalCubit>().loadAnimal(widget.animalId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre este amigo'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, favoritesState) {
              return FavoriteButtonWidget(
                isFavorite: favoritesState.contains(widget.animalId),
                onPressed: () => context.read<FavoritesCubit>().toggleFavorite(
                  widget.animalId,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<AnimalCubit, AnimalState>(
        builder: (context, state) {
          if (state.status != AnimalStatus.failure &&
              (state.status == AnimalStatus.loading ||
                  state.selectedAnimal == null)) {
            return const LoadingStateWidget();
          }
          if (state.status == AnimalStatus.failure) {
            return ErrorStateWidget(
              message:
                  state.errorMessage ??
                  'Não foi possível carregar este animal.',
              onRetry: () =>
                  context.read<AnimalCubit>().loadAnimal(widget.animalId),
            );
          }
          return _buildDetailContent(context, state.selectedAnimal!);
        },
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, Animal animal) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: AspectRatio(
              aspectRatio: 1.35,
              child: animal.image.isEmpty
                  ? _buildImagePlaceholder(context)
                  : Image.network(
                      animal.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _buildImagePlaceholder(context),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            animal.name,
            style: Theme.of(context).textTheme.displaySmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${_genderLabel(animal.gender)} • ${animal.age}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          _buildInfoSection(
            context: context,
            title: 'A história de ${animal.name}',
            icon: Icons.auto_stories_outlined,
            text: animal.story,
          ),
          const SizedBox(height: 20),
          _buildInfoSection(
            context: context,
            title: 'Jeito de ser',
            icon: Icons.mood_outlined,
            text: animal.behavior,
          ),
          const SizedBox(height: 28),
          _buildAdoptionAction(context, animal),
        ],
      ),
    );
  }

  Widget _buildAdoptionAction(BuildContext context, Animal animal) {
    return BlocBuilder<AdoptionCubit, AdoptionState>(
      builder: (context, adoptionState) {
        final isInProcess = adoptionState.contains(animal.id);
        final errorMessage = adoptionState.status == AdoptionStatus.failure
            ? adoptionState.errorMessage
            : null;

        if (isInProcess) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Processo de adoção iniciado',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _confirmCancellation(context, animal),
                icon: const Icon(Icons.close),
                label: const Text('Cancelar processo'),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: () async {
                final adoptionCubit = context.read<AdoptionCubit>();
                await adoptionCubit.startProcess(animal.id);
                if (!context.mounted) return;
                if (!adoptionCubit.isInProcess(animal.id)) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processo de adoção iniciado.')),
                );
              },
              icon: const Icon(Icons.volunteer_activism_outlined),
              label: const Text('Iniciar processo de adoção'),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _confirmCancellation(BuildContext context, Animal animal) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar processo?'),
        content: Text(
          'O processo de adoção de ${animal.name} será removido do seu perfil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Continuar processo'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancelar processo'),
          ),
        ],
      ),
    );

    if (shouldCancel != true || !context.mounted) return;
    final adoptionCubit = context.read<AdoptionCubit>();
    await adoptionCubit.cancelProcess(animal.id);
    if (!context.mounted) return;
    if (adoptionCubit.isInProcess(animal.id)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processo de adoção cancelado.')),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      alignment: Alignment.center,
      child: Icon(
        Icons.pets,
        size: 72,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  String _genderLabel(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
      case 'macho':
        return 'Macho';
      case 'female':
      case 'fêmea':
      case 'femea':
        return 'Fêmea';
      default:
        return gender;
    }
  }

  Widget _buildInfoSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9E4DC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

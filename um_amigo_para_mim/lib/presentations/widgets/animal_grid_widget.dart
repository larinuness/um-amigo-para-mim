import 'package:flutter/material.dart';

import '../../domain/entities/animal.dart';
import 'animal_card_widget.dart';

class AnimalGridWidget extends StatelessWidget {
  const AnimalGridWidget({
    super.key,
    required this.animals,
    required this.favoriteIds,
    required this.onAnimalTap,
    required this.onFavoriteToggle,
  });

  final List<Animal> animals;
  final Set<String> favoriteIds;
  final ValueChanged<Animal> onAnimalTap;
  final ValueChanged<Animal> onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.69,
      ),
      itemCount: animals.length,
      itemBuilder: (context, index) {
        final animal = animals[index];
        return AnimalCardWidget(
          animal: animal,
          isFavorite: favoriteIds.contains(animal.id),
          onTap: () => onAnimalTap(animal),
          onFavoriteToggle: () => onFavoriteToggle(animal),
        );
      },
    );
  }
}

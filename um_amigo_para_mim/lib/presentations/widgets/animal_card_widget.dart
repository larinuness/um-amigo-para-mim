import 'package:flutter/material.dart';

import '../../domain/entities/animal.dart';
import 'favorite_button_widget.dart';

class AnimalCardWidget extends StatelessWidget {
  const AnimalCardWidget({
    super.key,
    required this.animal,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final Animal animal;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildAnimalImage(context, animal),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                      ),
                      child: FavoriteButtonWidget(
                        isFavorite: isFavorite,
                        onPressed: onFavoriteToggle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_genderLabel(animal.gender)} • ${animal.age}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildAnimalImage(BuildContext context, Animal animal) {
    final placeholder = Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      alignment: Alignment.center,
      child: Icon(
        animal.species.toLowerCase() == 'cat' ? Icons.pets : Icons.cruelty_free,
        size: 52,
        color: Theme.of(context).colorScheme.primary,
      ),
    );

    if (animal.image.isEmpty) return placeholder;

    return Image.network(
      animal.image,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return placeholder;
      },
    );
  }
}

import 'package:flutter/material.dart';

class FavoriteButtonWidget extends StatelessWidget {
  const FavoriteButtonWidget({
    super.key,
    required this.isFavorite,
    required this.onPressed,
    this.size = 22,
  });

  final bool isFavorite;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        size: size,
      ),
      color: isFavorite
          ? Theme.of(context).colorScheme.secondary
          : Theme.of(context).colorScheme.onSurfaceVariant,
      tooltip: isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
      visualDensity: VisualDensity.compact,
    );
  }
}

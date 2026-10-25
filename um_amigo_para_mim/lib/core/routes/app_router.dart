import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentations/pages/animal_detail_page.dart';
import '../../presentations/pages/animals_page.dart';
import '../../presentations/pages/profile_page.dart';
import '../../presentations/pages/species_selection_page.dart';

class AppRouter {
  const AppRouter._();

  static GoRouter create() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SpeciesSelectionPage(),
        ),
        GoRoute(
          path: '/animals/:species/:id',
          builder: (context, state) => AnimalDetailPage(
            species: state.pathParameters['species'] ?? 'dog',
            animalId: state.pathParameters['id'] ?? '',
          ),
        ),
        GoRoute(
          path: '/animals/:species',
          builder: (context, state) =>
              AnimalsPage(species: state.pathParameters['species'] ?? 'dog'),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Um amigo para mim')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/'),
            child: const Text('Voltar ao início'),
          ),
        ),
      ),
    );
  }
}

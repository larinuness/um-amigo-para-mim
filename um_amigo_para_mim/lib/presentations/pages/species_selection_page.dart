import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/species_card_widget.dart';

class SpeciesSelectionPage extends StatelessWidget {
  const SpeciesSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBrandMark(context),
                    IconButton(
                      onPressed: () => context.push('/profile'),
                      icon: const Icon(Icons.favorite_border),
                      tooltip: 'Meu perfil',
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encontre um amigo\npara a vida toda.',
                      style: Theme.of(context).textTheme.displaySmall
                          ?.copyWith(fontWeight: FontWeight.w800, height: 1.08),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Conheça animais que estão esperando por uma família cheia de carinho.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  mainAxisExtent: 220,
                ),
                delegate: SliverChildListDelegate([
                  SpeciesCardWidget(
                    title: 'Cachorros',
                    description: 'Leais, brincalhões e cheios de amor.',
                    icon: Icons.cruelty_free,
                    color: const Color(0xFFE98A5B),
                    onTap: () => context.push('/animals/dog'),
                  ),
                  SpeciesCardWidget(
                    title: 'Gatos',
                    description: 'Independentes, curiosos e carinhosos.',
                    icon: Icons.pets,
                    color: const Color(0xFF6C8BC5),
                    onTap: () => context.push('/animals/cat'),
                  ),
                ]),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 24),
              sliver: SliverToBoxAdapter(child: SizedBox()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandMark(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.pets, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          'Um amigo\npara mim',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800, height: 1),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:um_amigo_para_mim/domain/entities/animal.dart';
import 'package:um_amigo_para_mim/presentations/widgets/animal_card_widget.dart';

void main() {
  testWidgets('exibe os dados do animal e responde ao favorito', (
    tester,
  ) async {
    var favoriteTapped = false;
    const animal = Animal(
      id: 'dog-01',
      name: 'Thor',
      species: 'dog',
      gender: 'male',
      age: '2 anos',
      image: '',
      story: 'Resgatado.',
      behavior: 'Docil.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 420,
            child: AnimalCardWidget(
              animal: animal,
              isFavorite: false,
              onTap: () {},
              onFavoriteToggle: () => favoriteTapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Thor'), findsOneWidget);
    expect(find.text('Macho • 2 anos'), findsOneWidget);
    await tester.tap(find.byTooltip('Adicionar aos favoritos'));

    expect(favoriteTapped, isTrue);
  });
}

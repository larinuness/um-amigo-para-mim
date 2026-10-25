import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:um_amigo_para_mim/presentations/widgets/species_card_widget.dart';

void main() {
  testWidgets('mantem o conteudo do card de especie dentro dos limites', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 220,
            child: SpeciesCardWidget(
              title: 'Cachorros',
              description: 'Leais, brincalhoes e cheios de amor.',
              icon: Icons.cruelty_free,
              color: Colors.orange,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Cachorros'), findsOneWidget);
  });
}

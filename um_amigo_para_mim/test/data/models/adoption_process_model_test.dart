import 'package:flutter_test/flutter_test.dart';
import 'package:um_amigo_para_mim/data/models/adoption_process_model.dart';
import 'package:um_amigo_para_mim/domain/entities/adoption_process.dart';

void main() {
  test('converte um processo de adoção a partir de JSON', () {
    final process = AdoptionProcessModel.fromJson({
      'id': 'profile-1__dog-01',
      'animalId': 'dog-01',
      'profileId': 'profile-1',
      'status': 'started',
      'startedAt': '2026-10-26T12:00:00.000Z',
      'updatedAt': '2026-10-26T12:00:00.000Z',
    });

    expect(process.id, 'profile-1__dog-01');
    expect(process.animalId, 'dog-01');
    expect(process.profileId, 'profile-1');
    expect(process.status, AdoptionProcessStatus.started);
    expect(process.isActive, isTrue);
  });

  test('serializa um processo cancelado', () {
    final process = AdoptionProcessModel(
      id: 'profile-1__dog-01',
      animalId: 'dog-01',
      profileId: 'profile-1',
      status: AdoptionProcessStatus.cancelled,
      startedAt: DateTime.utc(2026, 10, 26, 12),
      updatedAt: DateTime.utc(2026, 10, 26, 13),
    );

    expect(process.toJson()['status'], 'cancelled');
    expect(process.toJson()['animalId'], 'dog-01');
  });
}

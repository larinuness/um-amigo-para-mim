import 'package:equatable/equatable.dart';

enum AdoptionProcessStatus { started, cancelled }

class AdoptionProcess extends Equatable {
  const AdoptionProcess({
    required this.id,
    required this.animalId,
    required this.profileId,
    required this.status,
    required this.startedAt,
    required this.updatedAt,
  });

  final String id;
  final String animalId;
  final String profileId;
  final AdoptionProcessStatus status;
  final DateTime startedAt;
  final DateTime updatedAt;

  bool get isActive => status == AdoptionProcessStatus.started;

  AdoptionProcess copyWith({
    AdoptionProcessStatus? status,
    DateTime? startedAt,
    DateTime? updatedAt,
  }) {
    return AdoptionProcess(
      id: id,
      animalId: animalId,
      profileId: profileId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    animalId,
    profileId,
    status,
    startedAt,
    updatedAt,
  ];
}

import '../../domain/entities/adoption_process.dart';

class AdoptionProcessModel extends AdoptionProcess {
  const AdoptionProcessModel({
    required super.id,
    required super.animalId,
    required super.profileId,
    required super.status,
    required super.startedAt,
    required super.updatedAt,
  });

  factory AdoptionProcessModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().toUtc();
    return AdoptionProcessModel(
      id: _readString(json, 'id'),
      animalId: _readString(json, 'animalId'),
      profileId: _readString(json, 'profileId'),
      status: _readStatus(json['status']),
      startedAt: _readDate(json['startedAt'], fallback: now),
      updatedAt: _readDate(json['updatedAt'], fallback: now),
    );
  }

  factory AdoptionProcessModel.fromEntity(AdoptionProcess process) {
    return AdoptionProcessModel(
      id: process.id,
      animalId: process.animalId,
      profileId: process.profileId,
      status: process.status,
      startedAt: process.startedAt,
      updatedAt: process.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'animalId': animalId,
    'profileId': profileId,
    'status': _statusToString(status),
    'startedAt': startedAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  static String _readString(Map<String, dynamic> json, String key) {
    return json[key]?.toString() ?? '';
  }

  static DateTime _readDate(dynamic value, {required DateTime fallback}) {
    return DateTime.tryParse(value?.toString() ?? '')?.toUtc() ?? fallback;
  }

  static AdoptionProcessStatus _readStatus(dynamic value) {
    return value?.toString().toLowerCase() == 'cancelled'
        ? AdoptionProcessStatus.cancelled
        : AdoptionProcessStatus.started;
  }

  static String _statusToString(AdoptionProcessStatus status) {
    return status == AdoptionProcessStatus.cancelled ? 'cancelled' : 'started';
  }
}

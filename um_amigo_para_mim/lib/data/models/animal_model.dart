import '../../domain/entities/animal.dart';

class AnimalModel extends Animal {
  const AnimalModel({
    required super.id,
    required super.name,
    required super.species,
    required super.gender,
    required super.age,
    required super.image,
    required super.story,
    required super.behavior,
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: _readString(json, 'id'),
      name: _readString(json, 'name', fallback: 'Sem nome'),
      species: _readString(json, 'species'),
      gender: _readString(json, 'gender'),
      age: _readString(json, 'age'),
      image: _readString(json, 'image'),
      story: _readString(json, 'story'),
      behavior: _readString(json, 'behavior'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'species': species,
    'gender': gender,
    'age': age,
    'image': image,
    'story': story,
    'behavior': behavior,
  };

  static String _readString(
    Map<String, dynamic> json,
    String key, {
    String fallback = '',
  }) {
    final value = json[key];
    if (value == null) return fallback;
    return value.toString();
  }
}

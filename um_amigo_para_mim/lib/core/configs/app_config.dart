class AppConfig {
  const AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const fallbackAssetPath = 'mock_api/db.json';
  static const favoriteAnimalIdsKey = 'favorite_animal_ids';
}

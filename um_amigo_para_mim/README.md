# Um Amigo Para Mim

MVP Flutter de adoção de animais, criado para demonstrar navegação, Clean Architecture, Cubits, integração HTTP e persistência local de favoritos.

## Executar

Para usar a API local, instale as dependências e inicie o JSON Server:

```bash
cd mock_api
npm install
npm run api
```

Em outro terminal, execute o aplicativo apontando para a API:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

No desktop, use `http://localhost:3000`. Se a API estiver indisponível, o app usa automaticamente `mock_api/db.json` como fallback.

## Validação

```bash
flutter analyze
flutter test
```

Os favoritos são persistidos pela chave `favorite_animal_ids` usando `SharedPreferences`.

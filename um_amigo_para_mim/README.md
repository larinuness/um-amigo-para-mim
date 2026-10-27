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

No desktop, use `http://localhost:3000`. Se a API estiver indisponível, o app exibe a tela de erro e oferece uma nova tentativa.

## Validação

```bash
flutter analyze
flutter test
```

Os favoritos são persistidos pela chave `favorite_animal_ids` usando `SharedPreferences`.

No perfil, a aba **Em processo** mostra os animais para os quais o usuário iniciou
um processo de adoção. O processo é iniciado na tela de detalhes, pode ser
cancelado e usa um `profileId` anônimo persistido localmente. A Mock API mantém
os registros em `adoptionProcesses`; se ela estiver indisponível, o aplicativo
exibe a tela de erro e não usa dados locais como fallback.

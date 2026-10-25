# Plano do projeto — Um Amigo Para Mim

## 1. Objetivo

Criar um aplicativo Flutter de adoção de animais para demonstrar, em uma entrevista de emprego:

- Navegação entre telas usando rotas.
- Gerenciamento de estado global.
- Requisições HTTP para uma API local.
- Organização baseada em Clean Architecture.
- Persistência local dos animais favoritos.
- Testes unitários e testes de widgets.

O aplicativo será um MVP. Não haverá login, cadastro de usuário, processo real de adoção ou backend de produção.

## 2. Fluxo principal

1. O usuário acessa a tela inicial.
2. Escolhe entre cachorro e gato.
3. Visualiza os animais em um grid de duas colunas.
4. Cada card mostra imagem, nome, sexo e botão de favorito.
5. Ao tocar em um animal, acessa a tela de detalhes.
6. A tela de detalhes mostra história, comportamento e informações básicas.
7. O usuário pode favoritar ou desfavoritar o animal no grid ou nos detalhes.
8. A tela de perfil mostra todos os animais favoritados.

## 3. Rotas

| Rota | Tela |
|---|---|
| `/` | Seleção de cachorro ou gato |
| `/animals/:species` | Lista de animais por espécie |
| `/animals/:species/:id` | Detalhes do animal |
| `/profile` | Perfil com animais favoritos |

Será utilizado `go_router` para centralizar a configuração das rotas em `core/routes/`.

## 4. Arquitetura

```text
lib/
├── core/
│   ├── configs/
│   │   ├── app_config.dart
│   │   └── dependency_injection.dart
│   ├── themes/
│   │   └── app_theme.dart
│   └── routes/
│       └── app_router.dart
├── data/
│   ├── models/
│   │   └── animal_model.dart
│   └── repositories/
│       ├── animal_repository_impl.dart
│       └── profile_repository_impl.dart
├── domain/
│   ├── repositories/
│   │   ├── animal_repository.dart
│   │   └── profile_repository.dart
│   └── usecases/
│       ├── animal_use_case.dart
│       └── profile_use_case.dart
├── presentations/
│   ├── cubits/
│   │   ├── animal_cubit.dart
│   │   ├── animal_state.dart
│   │   ├── favorites_cubit.dart
│   │   └── favorites_state.dart
│   ├── pages/
│   │   ├── species_selection_page.dart
│   │   ├── animals_page.dart
│   │   ├── animal_detail_page.dart
│   │   └── profile_page.dart
│   └── widgets/
│       ├── species_card_widget.dart
│       ├── animal_card_widget.dart
│       ├── animal_grid_widget.dart
│       ├── favorite_button_widget.dart
│       ├── loading_state_widget.dart
│       ├── error_state_widget.dart
│       └── empty_state_widget.dart
└── main.dart
```

### Core

Conterá configurações compartilhadas da aplicação:

- URL base da API.
- Injeção manual de dependências.
- Tema visual.
- Configuração das rotas.

### Data

Conterá os modelos de dados e as implementações concretas dos repositories.

O `AnimalRepositoryImpl` será responsável por chamar diretamente o endpoint HTTP, converter o JSON em modelo e utilizar o arquivo local como fallback quando a API estiver indisponível.

O `ProfileRepositoryImpl` será responsável por ler e persistir os IDs dos favoritos usando `SharedPreferences`.

Não será criada uma camada separada de data sources, pois o escopo do projeto não exige múltiplas fontes de dados independentes.

### Domain

Conterá as interfaces dos repositories e as regras de negócio.

`AnimalRepository`:

```dart
abstract class AnimalRepository {
  Future<List<Animal>> getAnimalsBySpecies(String species);
  Future<Animal> getAnimalById(String id);
  Future<List<Animal>> getAllAnimals();
}
```

`ProfileRepository`:

```dart
abstract class ProfileRepository {
  Future<List<String>> getFavoriteIds();
  Future<void> toggleFavorite(String animalId);
  Future<bool> isFavorite(String animalId);
}
```

`AnimalUseCase` reunirá as operações relacionadas aos animais:

- Buscar animais por espécie.
- Buscar detalhes de um animal.
- Buscar todos os animais.

`ProfileUseCase` reunirá as operações relacionadas ao perfil:

- Carregar favoritos.
- Favoritar e desfavoritar animais.
- Consultar animais favoritos.

### Presentations

Conterá as telas, widgets e gerenciamento de estado.

Serão utilizados dois Cubits:

- `AnimalCubit`: carregamento, listagem, detalhes, loading, sucesso e erro.
- `FavoritesCubit`: carregamento, inclusão, remoção e persistência dos favoritos.

Cada Cubit terá seu estado em um arquivo separado (`animal_state.dart` e `favorites_state.dart`), mantendo a lógica de estado independente da lógica de negócio do Cubit.

Todos os arquivos de páginas terão o sufixo `_page.dart` e todos os arquivos de widgets terão o sufixo `_widget.dart`, inclusive os estados de erro, carregamento e vazio.

## 5. Injeção de dependência

A aplicação terá injeção de dependência manual, configurada em:

```text
lib/core/configs/dependency_injection.dart
```

O arquivo será responsável por criar e conectar:

```text
http.Client
  → AnimalRepositoryImpl
  → AnimalUseCase
  → AnimalCubit

SharedPreferences
  → ProfileRepositoryImpl
  → ProfileUseCase
  → FavoritesCubit
```

Os objetos serão disponibilizados para a árvore de widgets usando `RepositoryProvider` e `BlocProvider`.

Não será utilizado `get_it`, pois a injeção manual é suficiente para o tamanho do projeto e facilita a explicação durante a entrevista.

Nos testes, repositories, clientes HTTP e dependências locais poderão ser substituídos por mocks ou implementações falsas.

## 6. API local

Será utilizado JSON Server para simular uma API REST local. A versão planejada é `json-server@0.17.4`.

Estrutura:

```text
mock_api/
├── db.json
└── package.json
```

Endpoints:

```text
GET /animals?species=dog
GET /animals?species=cat
GET /animals/:id
GET /animals
```

Exemplo de animal:

```json
{
  "id": "dog-01",
  "name": "Thor",
  "species": "dog",
  "gender": "male",
  "age": "2 anos",
  "image": "assets/images/thor.jpg",
  "story": "Thor foi resgatado e aguarda uma família.",
  "behavior": "Brincalhão, dócil e sociável."
}
```

O arquivo `mock_api/db.json` também será incluído como asset do Flutter. Assim, se o JSON Server estiver indisponível, o repository poderá carregar os mesmos dados localmente.

A URL da API será configurável por variável de ambiente:

```text
--dart-define=API_BASE_URL=http://10.0.2.2:3000
```

O endereço `10.0.2.2` será utilizado para acessar o computador host a partir do Android Emulator. Para execução em desktop, será utilizado `localhost`; para dispositivo físico, será necessário informar o IP da máquina na rede local.

## 7. Persistência dos favoritos

Os favoritos serão armazenados localmente pela chave:

```text
favorite_animal_ids
```

Será persistida uma lista de IDs. O perfil carregará os animais disponíveis e exibirá apenas aqueles cujos IDs estejam salvos.

Comportamentos obrigatórios:

- Atualizar o botão de favorito imediatamente.
- Manter o estado ao navegar entre telas.
- Remover o animal do perfil ao desfavoritar.
- Manter os favoritos após fechar e reabrir o aplicativo.
- Exibir estado vazio quando não houver favoritos.

## 8. Dependências

Dependências principais:

- `flutter_bloc`
- `equatable`
- `go_router`
- `http`
- `shared_preferences`

Dependências de desenvolvimento:

- `bloc_test`
- `mocktail`

## 9. Testes

Serão implementados:

- Testes de conversão do `AnimalModel` a partir de JSON.
- Testes do `AnimalRepositoryImpl` com cliente HTTP mockado.
- Teste do fallback local quando a API falhar.
- Testes do `ProfileRepositoryImpl` com armazenamento local simulado.
- Testes do `AnimalUseCase`.
- Testes do `ProfileUseCase`.
- Testes do `AnimalCubit` para loading, sucesso e erro.
- Testes do `FavoritesCubit` para carregar, adicionar, remover e persistir favoritos.
- Testes de widgets para navegação, grid, detalhes, favoritos, erro e estado vazio.

Comandos de validação:

```text
flutter analyze
flutter test
```

## 10. Critérios de aceite

- O aplicativo inicia na tela de escolha entre cachorro e gato.
- A seleção abre o grid correspondente.
- O grid apresenta duas colunas.
- Cada animal apresenta imagem, nome, sexo e favorito.
- O clique abre os detalhes do animal.
- Os detalhes exibem história e comportamento.
- O favorito funciona no grid e nos detalhes.
- O perfil exibe os favoritos salvos.
- Os favoritos permanecem após reiniciar o aplicativo.
- O app realiza chamadas HTTP para o JSON Server.
- O app possui fallback local quando a API não estiver disponível.
- As rotas funcionam entre todas as telas.
- O estado dos favoritos é global.
- O código segue a estrutura definida de Clean Architecture.
- `flutter analyze` e `flutter test` são executados sem falhas.

## 11. Execução da API local

Na pasta `mock_api`:

```text
npm install
npm run api
```

Em outro terminal:

```text
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

## 12. Fora do escopo

- Autenticação.
- Cadastro de usuário.
- Processo real de adoção.
- Integração com backend de produção.
- Upload de imagens.
- Chat com abrigo ou responsável pelo animal.
- Paginação real.
- Notificações.

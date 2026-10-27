# Plano do projeto — Um Amigo Para Mim

> Versão 2.1 · Atualizado em 26/10/2026

## 1. Objetivo

Criar um aplicativo Flutter de descoberta e adoção responsável de animais para demonstrar, em uma entrevista de emprego:

- navegação entre telas usando rotas;
- gerenciamento de estado global;
- requisições HTTP para uma API local;
- organização baseada em Clean Architecture;
- persistência local de favoritos e dos processos na API;
- tela de erro e nova tentativa quando a API estiver indisponível;
- testes unitários, de Cubits e de widgets.

O aplicativo continua sendo um MVP. O processo de adoção apresentado é uma simulação de interesse: não existe autenticação, formulário real, análise por abrigo ou adoção efetivada.

## 2. Fluxos principais

### Descoberta e favoritos

1. O usuário acessa a tela inicial.
2. Escolhe entre cachorro e gato.
3. Visualiza os animais em um grid de duas colunas.
4. Cada card mostra imagem, nome, sexo, idade e botão de favorito.
5. Ao tocar em um animal, acessa a tela de detalhes.
6. A tela de detalhes mostra história, comportamento e informações básicas.
7. O usuário pode favoritar ou desfavoritar o animal no grid ou nos detalhes.

### Processo de adoção

1. O usuário abre os detalhes de um animal.
2. Toca em **Iniciar processo de adoção**.
3. O animal passa a aparecer na aba **Em processo** do perfil.
4. O usuário pode cancelar o processo após uma confirmação.
5. O processo de adoção é independente do favorito: iniciar uma adoção não favorita automaticamente o animal.

### Perfil

O perfil possui duas abas:

- **Curtidos**: animais favoritados pelo usuário;
- **Em processo**: animais com processo de adoção iniciado.

## 3. Rotas

| Rota | Tela |
|---|---|
| `/` | Seleção de cachorro ou gato |
| `/animals/:species` | Lista de animais por espécie |
| `/animals/:species/:id` | Detalhes do animal |
| `/profile` | Perfil com as abas Curtidos e Em processo |

É utilizado `go_router` para centralizar a configuração das rotas em `lib/core/routes/`.

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
│   │   ├── animal_model.dart
│   │   └── adoption_process_model.dart
│   └── repositories/
│       ├── animal_repository_impl.dart
│       ├── adoption_repository_impl.dart
│       ├── in_memory_adoption_repository.dart
│       ├── in_memory_profile_repository.dart
│       └── profile_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── animal.dart
│   │   └── adoption_process.dart
│   ├── repositories/
│   │   ├── animal_repository.dart
│   │   ├── adoption_repository.dart
│   │   └── profile_repository.dart
│   └── usecases/
│       ├── animal_use_case.dart
│       ├── adoption_use_case.dart
│       └── profile_use_case.dart
├── presentations/
│   ├── cubits/
│   │   ├── adoption_cubit.dart
│   │   ├── adoption_state.dart
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

Concentra configurações compartilhadas:

- URL base da API;
- chave do perfil anônimo;
- injeção manual de dependências;
- tema visual;
- configuração das rotas.

### Data

Contém os modelos e as implementações concretas dos repositories.

`AnimalRepositoryImpl` chama os endpoints HTTP, converte o JSON em modelos e propaga falhas para a camada de apresentação.

`ProfileRepositoryImpl` persiste os IDs de favoritos usando `SharedPreferences`.

`AdoptionRepositoryImpl` consulta e atualiza os processos exclusivamente na Mock API. Falhas da API são propagadas para que a interface mostre a tela de erro.

`InMemoryAdoptionRepository` é usada nos testes e previews para evitar dependência de rede ou armazenamento real.

### Domain

Contém entidades, contratos dos repositories e regras de acesso aos dados.

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

`AdoptionRepository`:

```dart
abstract class AdoptionRepository {
  Future<List<AdoptionProcess>> getActiveProcesses();
  Future<AdoptionProcess> startProcess(String animalId);
  Future<void> cancelProcess(String animalId);
}
```

`AdoptionProcess` contém:

- `id` do processo;
- `animalId`;
- `profileId` anônimo;
- status `started` ou `cancelled`;
- datas de início e atualização.

### Presentations

São utilizados três Cubits globais:

- `AnimalCubit`: carregamento, listagem, detalhes, loading, sucesso e erro;
- `FavoritesCubit`: carregamento, inclusão, remoção e persistência dos favoritos;
- `AdoptionCubit`: carregamento, início, cancelamento e exibição dos processos ativos.

Cada Cubit possui seu estado em arquivo separado. A lógica de negócio permanece nos use cases e repositories.

## 5. Injeção de dependência

A aplicação usa injeção manual em `lib/core/configs/dependency_injection.dart`.

```text
http.Client
  ├── AnimalRepositoryImpl
  │     └── AnimalUseCase
  │           └── AnimalCubit
  └── AdoptionRepositoryImpl
        └── AdoptionUseCase
              └── AdoptionCubit

SharedPreferences
  ├── ProfileRepositoryImpl
  │     └── ProfileUseCase
  │           └── FavoritesCubit
  └── AdoptionRepositoryImpl
```

Os objetos são disponibilizados na árvore de widgets usando `RepositoryProvider` e `BlocProvider`.

Não é utilizado `get_it`, pois a injeção manual é suficiente para o tamanho do projeto e facilita a explicação durante a entrevista.

## 6. API local

É utilizado JSON Server `0.17.4` para simular uma API REST local.

Estrutura:

```text
mock_api/
├── db.json
└── package.json
```

### Endpoints de animais

```text
GET /animals?species=dog
GET /animals?species=cat
GET /animals/:id
GET /animals
```

### Endpoints de adoção

```text
GET   /adoptionProcesses?profileId={profileId}&status=started
GET   /adoptionProcesses?profileId={profileId}&animalId={animalId}
POST  /adoptionProcesses
PATCH /adoptionProcesses/:id
```

Exemplo de processo:

```json
{
  "id": "profile-123__dog-01",
  "profileId": "profile-123",
  "animalId": "dog-01",
  "status": "started",
  "startedAt": "2026-10-26T12:00:00.000Z",
  "updatedAt": "2026-10-26T12:00:00.000Z"
}
```

O ID é determinístico por combinação de `profileId` e `animalId`, evitando processos duplicados.

O arquivo `mock_api/db.json` é usado pelo JSON Server. O aplicativo não o carrega como fallback e não mantém processos de adoção em cache local.

A URL da API é configurável por variável de ambiente:

```text
--dart-define=API_BASE_URL=http://10.0.2.2:3000
```

- Android Emulator: usar `10.0.2.2` para acessar o computador host.
- Desktop: usar `http://localhost:3000`.
- Dispositivo físico: usar o IP da máquina na rede local.
- Timeout das requisições: 5 segundos.

## 7. Persistência dos favoritos

Os favoritos são armazenados pela chave:

```text
favorite_animal_ids
```

É persistida uma lista de IDs. O perfil carrega os animais disponíveis e exibe apenas os animais cujos IDs estejam salvos.

Comportamentos obrigatórios:

- atualizar o botão de favorito imediatamente;
- manter o estado ao navegar entre telas;
- remover o animal do perfil ao desfavoritar;
- manter favoritos após fechar e reabrir o aplicativo;
- exibir estado vazio quando não houver favoritos.

## 8. Persistência dos processos de adoção

Como o MVP não possui autenticação, cada instalação recebe um identificador anônimo persistido em:

```text
anonymous_profile_id
```

Comportamentos obrigatórios:

- iniciar o processo somente nos detalhes do animal;
- não favoritar automaticamente o animal;
- impedir registros duplicados para o mesmo animal e perfil;
- atualizar a aba “Em processo” após a confirmação da API;
- confirmar antes de cancelar;
- remover o animal da aba após o cancelamento;
- mostrar a tela de erro quando a API estiver indisponível;
- manter o `profileId` anônimo para consultar os processos novamente quando a API voltar.

O status `started` aparece no perfil. O status `cancelled` permanece na Mock API, mas não aparece na lista de processos ativos.

## 9. Dependências

Dependências principais:

- `flutter_bloc`;
- `equatable`;
- `go_router`;
- `http`;
- `shared_preferences`.

Dependências de desenvolvimento:

- `bloc_test`;
- `mocktail`.

## 10. Testes

### Testes automatizados

- conversão do `AnimalModel` a partir de JSON;
- conversão e serialização do `AdoptionProcessModel`;
- `AnimalRepositoryImpl` com cliente HTTP mockado;
- propagação de falhas da API para a tela de erro;
- `AdoptionRepositoryImpl` com API mockada;
- erros de indisponibilidade da API na adoção;
- prevenção de duplicidade de processos;
- `ProfileRepositoryImpl` com armazenamento local simulado;
- `AnimalUseCase`, `ProfileUseCase` e `AdoptionUseCase`;
- `AnimalCubit` para loading, sucesso e erro;
- `FavoritesCubit` para carregar, adicionar, remover e persistir favoritos;
- `AdoptionCubit` para carregar, iniciar e cancelar processos;
- widgets e páginas para navegação, detalhes, favoritos, abas e estados vazios;
- confirmação de cancelamento do processo.

### Comandos de validação

```text
flutter analyze
flutter test
```

## 11. Critérios de aceite

- O aplicativo inicia na tela de escolha entre cachorro e gato.
- A seleção abre o grid correspondente.
- O grid apresenta duas colunas.
- Cada animal apresenta imagem, nome, sexo, idade e favorito.
- O clique abre os detalhes do animal.
- Os detalhes exibem história e comportamento.
- O favorito funciona no grid e nos detalhes.
- O perfil possui as abas “Curtidos” e “Em processo”.
- Iniciar adoção nos detalhes exibe o animal em “Em processo”.
- Iniciar adoção não altera os favoritos.
- Não são criados processos duplicados.
- Cancelar exige confirmação e remove o animal da aba.
- O processo permanece salvo após reiniciar o aplicativo.
- O app realiza chamadas HTTP para o JSON Server.
- A coleção `adoptionProcesses` está disponível na Mock API.
- A tela de erro é exibida quando a API estiver indisponível.
- Nenhuma operação é confirmada ou mantida localmente sem resposta da API.
- As rotas funcionam entre todas as telas.
- Os estados de loading, erro, retry e vazio são exibidos corretamente.
- O estado de favoritos e adoções permanece global.
- O código segue a estrutura definida de Clean Architecture.
- `flutter analyze` e `flutter test` são executados sem falhas.

## 12. Execução da API local

Na pasta `mock_api`:

```text
npm install
npm run api
```

Em outro terminal:

```text
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Para desktop:

```text
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

## 13. Fora do escopo do MVP

- autenticação;
- cadastro de usuário;
- formulário real de adoção;
- análise ou aprovação por abrigo;
- integração com backend de produção;
- contato real com responsáveis;
- upload de imagens;
- chat;
- paginação real;
- notificações;
- etapas avançadas do processo, como entrevista e aprovação.

## 14. Próximas evoluções

- adicionar formulário de manifestação de interesse;
- criar uma linha do tempo do processo;
- incluir estados como formulário enviado, em análise e aprovado;
- substituir o `profileId` anônimo por autenticação real;
- integrar abrigos e contatos reais;
- adicionar notificações sobre mudanças no processo.

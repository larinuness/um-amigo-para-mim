import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/configs/dependency_injection.dart';
import 'core/routes/app_router.dart';
import 'core/themes/app_theme.dart';
import 'domain/repositories/adoption_repository.dart';
import 'domain/repositories/animal_repository.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/adoption_use_case.dart';
import 'domain/usecases/animal_use_case.dart';
import 'domain/usecases/profile_use_case.dart';
import 'presentations/cubits/adoption_cubit.dart';
import 'presentations/cubits/animal_cubit.dart';
import 'presentations/cubits/favorites_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await DependencyInjection.create();
  runApp(MyApp(dependencies: dependencies));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AdoptionRepository>.value(
          value: dependencies.adoptionRepository,
        ),
        RepositoryProvider<AnimalRepository>.value(
          value: dependencies.animalRepository,
        ),
        RepositoryProvider<ProfileRepository>.value(
          value: dependencies.profileRepository,
        ),
        RepositoryProvider<AdoptionUseCase>.value(
          value: dependencies.adoptionUseCase,
        ),
        RepositoryProvider<AnimalUseCase>.value(
          value: dependencies.animalUseCase,
        ),
        RepositoryProvider<ProfileUseCase>.value(
          value: dependencies.profileUseCase,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AdoptionCubit>(
            create: (_) => AdoptionCubit(dependencies.adoptionUseCase)..load(),
          ),
          BlocProvider<AnimalCubit>(
            create: (_) => AnimalCubit(dependencies.animalUseCase),
          ),
          BlocProvider<FavoritesCubit>(
            create: (_) => FavoritesCubit(dependencies.profileUseCase)..load(),
          ),
        ],
        child: MaterialApp.router(
          title: 'Um amigo para mim',
          theme: AppTheme.light,
          routerConfig: AppRouter.create(),
        ),
      ),
    );
  }
}

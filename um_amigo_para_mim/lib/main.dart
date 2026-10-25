import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/configs/dependency_injection.dart';
import 'core/routes/app_router.dart';
import 'core/themes/app_theme.dart';
import 'domain/repositories/animal_repository.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/animal_use_case.dart';
import 'domain/usecases/profile_use_case.dart';
import 'presentations/cubits/animal_cubit.dart';
import 'presentations/cubits/favorites_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await DependencyInjection.create();
  runApp(MyApp(dependencies: dependencies));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.dependencies});

  final AppDependencies? dependencies;

  @override
  Widget build(BuildContext context) {
    final appDependencies = dependencies ?? DependencyInjection.inMemory();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AnimalRepository>.value(
          value: appDependencies.animalRepository,
        ),
        RepositoryProvider<ProfileRepository>.value(
          value: appDependencies.profileRepository,
        ),
        RepositoryProvider<AnimalUseCase>.value(
          value: appDependencies.animalUseCase,
        ),
        RepositoryProvider<ProfileUseCase>.value(
          value: appDependencies.profileUseCase,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AnimalCubit>(
            create: (_) => AnimalCubit(appDependencies.animalUseCase),
          ),
          BlocProvider<FavoritesCubit>(
            create: (_) =>
                FavoritesCubit(appDependencies.profileUseCase)..load(),
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

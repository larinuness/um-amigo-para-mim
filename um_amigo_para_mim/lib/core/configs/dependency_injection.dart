import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/animal_repository_impl.dart';
import '../../data/repositories/in_memory_profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/animal_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/animal_use_case.dart';
import '../../domain/usecases/profile_use_case.dart';
import 'app_config.dart';

class AppDependencies {
  const AppDependencies({
    required this.animalRepository,
    required this.profileRepository,
    required this.animalUseCase,
    required this.profileUseCase,
  });

  final AnimalRepository animalRepository;
  final ProfileRepository profileRepository;
  final AnimalUseCase animalUseCase;
  final ProfileUseCase profileUseCase;
}

class DependencyInjection {
  const DependencyInjection._();

  static Future<AppDependencies> create() async {
    final preferences = await SharedPreferences.getInstance();
    return createWith(
      animalRepository: AnimalRepositoryImpl(
        client: http.Client(),
        baseUrl: AppConfig.apiBaseUrl,
      ),
      profileRepository: ProfileRepositoryImpl(preferences),
    );
  }

  static AppDependencies createWith({
    required AnimalRepository animalRepository,
    required ProfileRepository profileRepository,
  }) {
    return AppDependencies(
      animalRepository: animalRepository,
      profileRepository: profileRepository,
      animalUseCase: AnimalUseCase(animalRepository),
      profileUseCase: ProfileUseCase(profileRepository),
    );
  }

  static AppDependencies inMemory() {
    return createWith(
      animalRepository: AnimalRepositoryImpl(
        client: http.Client(),
        baseUrl: AppConfig.apiBaseUrl,
      ),
      profileRepository: InMemoryProfileRepository(),
    );
  }
}

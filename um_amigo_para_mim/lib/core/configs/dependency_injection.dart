import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/adoption_repository_impl.dart';
import '../../data/repositories/animal_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/adoption_repository.dart';
import '../../domain/repositories/animal_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/adoption_use_case.dart';
import '../../domain/usecases/animal_use_case.dart';
import '../../domain/usecases/profile_use_case.dart';
import 'app_config.dart';

class AppDependencies {
  const AppDependencies({
    required this.adoptionRepository,
    required this.animalRepository,
    required this.profileRepository,
    required this.adoptionUseCase,
    required this.animalUseCase,
    required this.profileUseCase,
  });

  final AdoptionRepository adoptionRepository;
  final AnimalRepository animalRepository;
  final ProfileRepository profileRepository;
  final AdoptionUseCase adoptionUseCase;
  final AnimalUseCase animalUseCase;
  final ProfileUseCase profileUseCase;
}

class DependencyInjection {
  const DependencyInjection._();

  static Future<AppDependencies> create() async {
    final preferences = await SharedPreferences.getInstance();
    final client = http.Client();
    return createWith(
      animalRepository: AnimalRepositoryImpl(
        client: client,
        baseUrl: AppConfig.apiBaseUrl,
      ),
      profileRepository: ProfileRepositoryImpl(preferences),
      adoptionRepository: AdoptionRepositoryImpl(
        client: client,
        baseUrl: AppConfig.apiBaseUrl,
        preferences: preferences,
      ),
    );
  }

  static AppDependencies createWith({
    required AnimalRepository animalRepository,
    required ProfileRepository profileRepository,
    required AdoptionRepository adoptionRepository,
  }) {
    return AppDependencies(
      adoptionRepository: adoptionRepository,
      animalRepository: animalRepository,
      profileRepository: profileRepository,
      adoptionUseCase: AdoptionUseCase(adoptionRepository),
      animalUseCase: AnimalUseCase(animalRepository),
      profileUseCase: ProfileUseCase(profileRepository),
    );
  }
}

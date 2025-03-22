import 'package:get_it/get_it.dart';
import 'package:medical_app/core/secrets/supabase_secrets.dart';
import 'package:medical_app/features/auth/data/datasource/supabase_remote.dart';
import 'package:medical_app/features/auth/data/repos/auth_repo_implementation.dart';
import 'package:medical_app/features/auth/domain/repos/auth_repos.dart';
import 'package:medical_app/features/auth/domain/usecases/user_login.dart';
import 'package:medical_app/features/auth/domain/usecases/user_register.dart';
import 'package:medical_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final initializedServices = GetIt.instance;

Future<void> initDependencies() async {
  final supabase = await Supabase.initialize(
    url: SupabaseSecrets.supabaseUrl,
    anonKey: SupabaseSecrets.key,
  );
  initializedServices.registerLazySingleton(() => supabase.client);
  
   _initAuth();
}

void _initAuth() {
  initializedServices.registerFactory<AuthRemoteSource>(
      () => AuthRemoteSourceImp(
        initializedServices()
        )
    );
  initializedServices.registerFactory<AuthRepos>(
    () => AuthReposImpl(
      initializedServices()
      )
    );
  initializedServices.registerFactory(
    () => UserRegister(
      initializedServices()
      )
    );
  initializedServices.registerFactory(
    () => UserLogin(
      initializedServices()
      )
    );
  initializedServices.registerLazySingleton(
    () => AuthBloc(
      userRegister: initializedServices(),
      userLogin: initializedServices()
      )
    );
}

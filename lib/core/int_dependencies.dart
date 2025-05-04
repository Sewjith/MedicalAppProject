import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_it/get_it.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/secrets/supabase_secrets.dart';
import 'package:medical_app/features/auth/data/datasource/supabase_remote.dart';
import 'package:medical_app/features/auth/data/repos/auth_repo_implementation.dart';
import 'package:medical_app/features/auth/domain/repos/auth_repos.dart';
import 'package:medical_app/features/auth/domain/usecases/active_user.dart';
import 'package:medical_app/features/auth/domain/usecases/user_login.dart';
import 'package:medical_app/features/auth/domain/usecases/user_register.dart';
import 'package:medical_app/features/auth/domain/usecases/user_sign_out.dart';
import 'package:medical_app/features/auth/domain/usecases/request_otp.dart';
import 'package:medical_app/features/auth/domain/usecases/verify_otp.dart';
import 'package:medical_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final initializedServices = GetIt.instance;

Future<void> initDependencies() async {
  final supabase = await Supabase.initialize(
    url: SupabaseSecrets.supabaseUrl,
    anonKey: SupabaseSecrets.key,
  );

  initializedServices.registerLazySingleton(() => supabase.client);
  initializedServices.registerLazySingleton(() => AppUserCubit());

  _initAuth();

  try {
    await dotenv.load(fileName: ".env");
    final stripePublishKey = dotenv.env["STRIPE_PUBLISH_KEY"];
    if (stripePublishKey == null || stripePublishKey.isEmpty) {
      print("❌ ERROR: Stripe publishable key not found in .env file.");
      throw Exception("Stripe publishable key not found in .env file.");
    } else {
      Stripe.publishableKey = stripePublishKey;
    }
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    Stripe.urlScheme = 'flutterstripe';
    print("Applying Stripe settings...");
    await Stripe.instance.applySettings();
    print("✅ Stripe settings applied successfully."); // Add log
  } catch (e) {
    print("❌❌❌ CRITICAL ERROR during Stripe initialization: $e");
    // You might want to re-throw or handle this critical failure appropriately
  }

  // await dotenv.load(fileName: ".env");
  // Stripe.publishableKey = dotenv.env["STRIPE_PUBLISH_KEY"]!;
  // Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  // Stripe.urlScheme = 'flutterstripe';
  // await Stripe.instance.applySettings();
}

void _initAuth() {
  initializedServices.registerFactory<AuthRemoteSource>(
    () => AuthRemoteSourceImp(
      initializedServices(),
    ),
  );

  initializedServices.registerFactory<AuthRepos>(
    () => AuthReposImpl(
      initializedServices(),
    ),
  );

  initializedServices.registerFactory(
    () => UserRegister(
      initializedServices(),
    ),
  );

  initializedServices.registerFactory(
    () => UserLogin(
      initializedServices(),
    ),
  );

  initializedServices.registerFactory(
    () => ActiveUser(
      initializedServices(),
    ),
  );

  initializedServices.registerFactory(
    () => UserSignOut(
      initializedServices(),
    ),
  );

  // ✅ Register OTP use cases
  initializedServices.registerFactory(
    () => RequestOtp(
      initializedServices(),
    ),
  );

  initializedServices.registerFactory(
    () => VerifyOtp(
      initializedServices(),
    ),
  );

  initializedServices.registerLazySingleton(
    () => AuthBloc(
      userRegister: initializedServices(),
      userLogin: initializedServices(),
      activeUser: initializedServices(),
      userSignOut: initializedServices(),
      requestOtp: initializedServices(), // Inject RequestOtp
      verifyOtp: initializedServices(),  // Inject VerifyOtp
      userCubit: initializedServices(),
    ),
  );
}

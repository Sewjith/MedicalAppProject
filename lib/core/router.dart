import 'package:go_router/go_router.dart';
import 'package:medical_app/core/main_layout.dart';
import 'package:medical_app/features/auth/presentation/screens/login_page.dart';
import 'package:medical_app/features/auth/presentation/screens/reset_password_page.dart';
import 'package:medical_app/features/patient_profile/profile.dart';
import 'package:medical_app/features/main/presentation/screens/home_page.dart';

final GoRouter appRouter =
    GoRouter(initialLocation: '/doctor_profile', routes: <RouteBase>[
  GoRoute(
    path: '/home',
    builder: (context, state) => const MainLayout(child: HomePage()),
  ),
  GoRoute(
    path: '/login',
    builder: (context, state) => const MainLayout(child: Login()),
  ),
  GoRoute(
    path: '/doctor_profile',
    builder: (context, state) => const MainLayout(child: PatientProfile()),
  ),
  GoRoute(
    path: '/reset-password',
    builder: (context, state) => const MainLayout(child: ForgotPassword()),
  ),
]);

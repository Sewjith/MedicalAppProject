import 'package:go_router/go_router.dart';
import 'package:medical_app/core/main_layout.dart';
import 'package:medical_app/features/auth/presentation/screens/login_page.dart';
import 'package:medical_app/features/auth/presentation/screens/register_page.dart';
import 'package:medical_app/features/auth/presentation/screens/reset_password_page.dart';
import 'package:medical_app/features/main/presentation/screens/home_page.dart';
import 'package:medical_app/features/patient_dashboard/dashboard.dart';

final GoRouter appRouter =
GoRouter(initialLocation: '/dashboard', routes: <RouteBase>[
  GoRoute(
    path: '/dashboard',
    builder: (context, state) => const MainLayout(child: Dashboard()),
  ),
  GoRoute(
    path: '/login',
    builder: (context, state) => const MainLayout(child: Login()),
  ),
  GoRoute(
    path: '/register',
    builder: (context, state) => const MainLayout(child: Register()),
  ),
  GoRoute(
    path: '/reset-password',
    builder: (context, state) => const MainLayout(child: ForgotPassword()),
  ),
]);

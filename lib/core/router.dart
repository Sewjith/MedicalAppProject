import 'package:go_router/go_router.dart';
import 'package:medical_app/core/main_layout.dart';
import 'package:medical_app/features/auth/presentation/screens/login_page.dart';
import 'package:medical_app/features/auth/presentation/screens/register_page.dart';
import 'package:medical_app/features/auth/presentation/screens/reset_password_page.dart';
import 'package:medical_app/features/main/presentation/screens/home_page.dart';
import 'package:medical_app/features/appoinment_history/appoinment.dart';

final GoRouter appRouter =
    GoRouter(initialLocation: '/appointment', routes: <RouteBase>[
  GoRoute(
    path: '/home',
    builder: (context, state) => const MainLayout(child: HomePage()),
  ),
  GoRoute(
    path: '/login',
    builder: (context, state) => const MainLayout(child: Login()),
  ),
  GoRoute(
    path: '/appointment',
    builder: (context, state) => const MainLayout(child: Appointment()),
  ),
  GoRoute(
    path: '/reset-password',
    builder: (context, state) => const MainLayout(child: ForgotPassword()),
  ),
]);

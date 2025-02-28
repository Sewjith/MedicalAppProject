import 'package:go_router/go_router.dart';
import 'package:medical_app/core/main_layout.dart';
import 'package:medical_app/features/Patient_Notes/presentation/screens/Patient_Notes.dart';
import 'package:medical_app/features/analytics/earnings.dart';
import 'package:medical_app/features/auth/presentation/screens/login_page.dart';
import 'package:medical_app/features/auth/presentation/screens/register_page.dart';
import 'package:medical_app/features/auth/presentation/screens/reset_password_page.dart';
import 'package:medical_app/features/doctor-search/domain/entities/doctor_profiles.dart';
import 'package:medical_app/features/doctor-search/presentation/screen/doctor_profile_page.dart';
import 'package:medical_app/features/doctor-search/presentation/screen/doctor_search_page.dart';
import 'package:medical_app/features/main/presentation/screens/home_page.dart';

final GoRouter appRouter =
    GoRouter(initialLocation: '/home', routes: <RouteBase>[
  GoRoute(
    path: '/home',
    builder: (context, state) => const MainLayout(child: HomePage()),
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
  GoRoute(
    path: '/earnings',
    builder: (context, state) => const MainLayout(child: Earnings()),
  ),
  GoRoute(
    path: '/doctor-profiles',
    builder: (context, state) => const MainLayout(child: DoctorProfilesPage()),
  ),
   GoRoute(
    path: '/Patient_Notes',
    builder: (context, state) => MainLayout(child: PatientManagementScreen()),
  ),
  GoRoute(
  path: '/doctor-profile',
  builder: (context, state) {
    final profile = state.extra as DoctorProfiles; // Cast to your entity
    return MainLayout(child: DoctorProfile(profile: profile)); // Pass the profile to the DoctorProfile widget
  },
  
)
]);

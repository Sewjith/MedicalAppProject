import 'package:go_router/go_router.dart';
import 'package:medical_app/core/main_layout.dart';
import 'package:medical_app/features/Doctor_Availability/Doctor_Availability.dart';
import 'package:medical_app/features/analytics/earnings.dart';
import 'package:medical_app/features/auth/presentation/screens/email_verify.dart';
import 'package:medical_app/features/auth/presentation/screens/login_page.dart';
import 'package:medical_app/features/auth/presentation/screens/register_page.dart';
import 'package:medical_app/features/auth/presentation/screens/reset_password_email_link.dart';
import 'package:medical_app/features/auth/presentation/screens/reset_password_page.dart';
import 'package:medical_app/features/doctor-search/data/model/doctor_list_model.dart';
import 'package:medical_app/features/doctor-search/domain/entities/doctor_profiles.dart';
import 'package:medical_app/features/doctor-search/presentation/screen/doctor_profile_page.dart';
import 'package:medical_app/features/doctor-search/presentation/screen/doctor_search_page.dart';
import 'package:medical_app/features/main/presentation/screens/home_page.dart';
import 'package:medical_app/features/teleconsultation/presentation/consultation_page.dart';
import 'package:medical_app/features/teleconsultation/presentation/index.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
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
      builder: (context, state) =>
          const MainLayout(child: DoctorProfilesPage()),
    ),
    GoRoute(
      path: '/consults',
      builder: (context, state) => const MainLayout(child: IndexPage()),
    ),
    GoRoute(
      path: '/doctor-availability',
      builder: (context, state) =>
          const MainLayout(child: DoctorAvailabilityPage()),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const MainLayout(child: DoctorProfilesPage()),
    ),
    GoRoute(
      path: '/video-call',
      builder: (context, state) {
        final Map<String, String> params = state.extra as Map<String, String>;
        return MainLayout(
          child: DoctorConsultation(
            appId: params['appId']!,
            token: params['token']!,
            channelName: params['channelName']!,
          ),
        );
      },
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final email = state.extra as String; // Retrieve email
        return OtpInputScreen(email: email);
      },
    ),
    GoRoute(
      path: '/doctor-profile',
      builder: (context, state) {
        final profile = state.extra as DoctorListModel;
        return MainLayout(child: DoctorProfile(profile: profile));
      },
    ),
  ],
);

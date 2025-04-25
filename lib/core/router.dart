import 'package:go_router/go_router.dart';
import 'package:medical_app/core/main_layout.dart';
import 'package:medical_app/features/Doctor/D_Appointment_schedule/Appointment_schedule.dart';
import 'package:medical_app/features/Doctor/doctor_dahboard/firstpage.dart';
import 'package:medical_app/features/Doctor/doctor_profile/profile.dart';
import 'package:medical_app/features/Patient/appoinment_history/appoinment.dart';
import 'package:medical_app/features/Patient/doctor-search/data/model/doctor_list_model.dart';
import 'package:medical_app/features/Patient/doctor-search/presentation/screen/doctor_profile_page.dart';
import 'package:medical_app/features/Patient/doctor-search/presentation/screen/doctor_search_page.dart';
import 'package:medical_app/features/Patient/help-center/presentation/pages/help_center_page.dart';
import 'package:medical_app/features/Patient/p_appointment_schedule/p_appointment_schedule.dart';
import 'package:medical_app/features/Patient/patient_dashboard/dashboard.dart';
import 'package:medical_app/features/Patient/patient_profile/profile.dart';
import 'package:medical_app/features/doctor/Doctor_Availability/Doctor_Availability.dart';
import 'package:medical_app/features/doctor/analytics/earnings.dart';
import 'package:medical_app/features/auth/presentation/screens/email_verify.dart';
import 'package:medical_app/features/auth/presentation/screens/login_page.dart';
import 'package:medical_app/features/auth/presentation/screens/register_page.dart';
import 'package:medical_app/features/auth/presentation/screens/reset_password_email_link.dart';
import 'package:medical_app/features/auth/presentation/screens/reset_password_page.dart';
import 'package:medical_app/features/main/presentation/screens/home_page.dart';
import 'package:medical_app/features/main_features/Digital_Health_Record/health_record.dart';
import 'package:medical_app/features/main_features/Emergency_Assistance/emergency_assistant.dart';
import 'package:medical_app/features/main_features/Medication%20Reminder/medication_reminder.dart';
import 'package:medical_app/features/main_features/Symptom_History_Tracker/SymptomTrackerScreen.dart';
import 'package:medical_app/features/main_features/chatbot/chat_screen.dart';
import 'package:medical_app/features/main_features/teleconsultation/presentation/consultation_page.dart';
import 'package:medical_app/features/main_features/teleconsultation/presentation/index.dart';


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
    GoRoute(
      path: '/p_dashboard',
      builder: (context, state) => const MainLayout(child: Dashboard()),
    ),
    GoRoute(
    path: '/help-center',
    builder: (context, state) => const MainLayout(child: HelpCentrePage()),
    ),
    GoRoute(
      path: '/p_profile',
      builder: (context, state) => const MainLayout(child: PatientProfile()),
    ),
    GoRoute(
      path: '/p_appointment',
      builder: (context, state) => const MainLayout(child: AppointmentSchedulePage()),
    ),
    GoRoute(
      path: '/p_appointment-history',
      builder: (context, state) => MainLayout(child: Appointment()),
    ),
    GoRoute(
      path: '/d_dashboard',
      builder: (context, state) => MainLayout(child: Profile()),
    ),
    GoRoute(
      path: '/d_appointment-schedule',
      builder: (context, state) => const MainLayout(child: DAppointmentManagementPage()),
    ),
    GoRoute(
      path: '/chatbot',
      builder: (context, state) => MainLayout(child: ChatScreen()),
    ),
     GoRoute(
      path: '/Digital-health',
      builder: (context, state) => const MainLayout(child: HealthRecordScreen()),
    ),
    GoRoute(
      path: '/emergency-assistance',
      builder: (context, state) => MainLayout(child: EmergencyAssistantPage()),
    ),
    GoRoute(
      path: '/medication-remainder',
      builder: (context, state) =>  MainLayout(child: Medication_Reminder()),
    ),
    GoRoute(
      path: '/SymptomTracker',
      builder: (context, state) =>const  MainLayout(child:  SymptomTrackerScreen()),
    )
  ],
);

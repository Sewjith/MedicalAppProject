// @annotate:modified:lib/core/router.dart
//@annotate:rewritten:lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/main_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:medical_app/features/Doctor/Patient_Management/d_add_edit_note_page.dart';
import 'package:medical_app/features/Doctor/Patient_Management/d_doctor_patient_list.dart';
import 'package:medical_app/features/Doctor/Patient_Management/d_patient_detail_page.dart';
import 'package:medical_app/features/Patient/hospitals_and_pharmacies/hospitals.dart';
import 'package:medical_app/features/Patient/hospitals_and_pharmacies/pharmacies.dart';

// --- Core & Common ---

// --- Auth ---
import 'package:medical_app/features/auth/presentation/screens/login_page.dart';
import 'package:medical_app/features/auth/presentation/screens/register_page.dart';
import 'package:medical_app/features/auth/presentation/screens/email_verify.dart';
import 'package:medical_app/features/auth/presentation/screens/reset_password_email_link.dart';
import 'package:medical_app/features/auth/presentation/screens/reset_password_page.dart';

// --- Main ---
import 'package:medical_app/features/main/presentation/screens/home_page.dart';

// --- Patient ---
import 'package:medical_app/features/Patient/patient_dashboard/dashboard.dart'
    as PatientDashboard;
import 'package:medical_app/features/Patient/patient_profile/profile.dart';
import 'package:medical_app/features/Patient/patient_profile/pages/edit_profile.dart';
import 'package:medical_app/features/Patient/patient_profile/pages/settings.dart';
import 'package:medical_app/features/Patient/patient_profile/pages/notifications.dart'
    as PatientNotifications;
import 'package:medical_app/features/Patient/patient_profile/pages/change_password.dart'
    as PatientChangePassword;
import 'package:medical_app/features/Patient/patient_profile/pages/delete_account.dart'
    as PatientDeleteAccount;
import 'package:medical_app/features/Patient/doctor-search/presentation/screen/doctor_search_page.dart';
import 'package:medical_app/features/Patient/doctor-search/presentation/screen/doctor_profile_page.dart';

import 'package:medical_app/features/Patient/p_appointment_schedule/p_appointment_schedule.dart';
import 'package:medical_app/features/Patient/p_appointment_schedule/p_appointment_confirmation.dart';
import 'package:medical_app/features/Patient/appoinment_history/appoinment.dart';
import 'package:medical_app/features/Patient/appoinment_history/details.dart';
import 'package:medical_app/features/Patient/appoinment_history/appoinment%20cancelation.dart';
import 'package:medical_app/features/Patient/appoinment_history/review2.dart';
import 'package:medical_app/features/Patient/patient_dashboard/pages/a-z.dart';
import 'package:medical_app/features/Patient/patient_dashboard/pages/favorite.dart';
import 'package:medical_app/features/Patient/patient_dashboard/pages/male_doctors.dart';
import 'package:medical_app/features/Patient/patient_dashboard/pages/female_doctors.dart';
import 'package:medical_app/features/Patient/help-center/presentation/pages/help_center_page.dart';

// --- Doctor ---
import 'package:medical_app/features/Doctor/doctor_dahboard/firstpage.dart'
    as DoctorDashboardEntry;
import 'package:medical_app/features/Doctor/doctor_profile/profile.dart'
    as DoctorProfileEntry;
import 'package:medical_app/features/Doctor/doctor_profile/pages/edit_profile.dart'
    as DoctorEditProfile; // Renamed import
import 'package:medical_app/features/Doctor/doctor_profile/pages/settings.dart'
    as DoctorSettings;
import 'package:medical_app/features/Doctor/doctor_profile/pages/terms_and_conditions.dart'
    as DoctorTerms;
import 'package:medical_app/features/Doctor/doctor_profile/pages/privacy_and_policy.dart'
    as DoctorPrivacy;
import 'package:medical_app/features/Doctor/doctor_profile/pages/change_passwords.dart'
    as DoctorChangePassword;
import 'package:medical_app/features/Doctor/doctor_profile/pages/delete_account.dart'
    as DoctorDeleteAccount;
import 'package:medical_app/features/Doctor/doctor_profile/pages/notifications.dart'
    as DoctorNotifications;
import 'package:medical_app/features/Doctor/D_Appointment_schedule/Appointment_schedule.dart';
import 'package:medical_app/features/Doctor/Doctor_Availability/Doctor_Availability.dart';
import 'package:medical_app/features/Doctor/d_prescription_tool/presentation/pages/prescription_selector_page.dart';
import 'package:medical_app/features/Doctor/doctor_dahboard/overview.dart';
import 'package:medical_app/features/Doctor/doctor_dahboard/inbox.dart';
import 'package:medical_app/features/Doctor/doctor_dahboard/message_detail.dart';
import 'package:medical_app/features/Doctor/D_consultation_history/consultation_history_page.dart';
import 'package:medical_app/features/Doctor/doctor_dahboard/earnings.dart'
    as DoctorDashboardEarnings;
import 'package:medical_app/features/main_features/health_articles/d_create_edit_article_page.dart';
import 'package:medical_app/features/main_features/health_articles/d_my_articles_page.dart';
import 'package:medical_app/features/main_features/health_articles/p_article_detail_page.dart';
import 'package:medical_app/features/main_features/health_articles/p_article_list_page.dart';
import 'package:medical_app/features/main_features/in-app-payments/payment_home.dart';

// --- Shared Features ---
import 'package:medical_app/features/main_features/teleconsultation/presentation/index.dart';
import 'package:medical_app/features/main_features/teleconsultation/presentation/consultation_page.dart';
import 'package:medical_app/features/main_features/Chat/screens/login_screen.dart';
import 'package:medical_app/features/main_features/Chat/screens/chat_screen.dart';
import 'package:medical_app/features/main_features/Digital_Health_Record/health_record.dart';
import 'package:medical_app/features/main_features/Digital_Health_Record/add_report.dart';
import 'package:medical_app/features/main_features/Emergency_Assistance/emergency_assistant.dart';
import 'package:medical_app/features/main_features/Emergency_Assistance/connecting_doc.dart';
import 'package:medical_app/features/main_features/Medication%20Reminder/medication_reminder.dart';
import 'package:medical_app/features/main_features/Medication%20Reminder/Vaccination_Reminder.dart';
import 'package:medical_app/features/main_features/Medication%20Reminder/pillDetails.dart';
import 'package:medical_app/features/main_features/Notification/screens/notifications_screen.dart';
import 'package:medical_app/features/main_features/Symptom_History_Tracker/SymptomTrackerScreen.dart';
import 'package:medical_app/features/main_features/chatbot/chat_screen.dart';

// --- Navigator Keys ---
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

// --- GoRouter Configuration ---
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    // ========================================================================
    // Routes OUTSIDE the MainLayout Shell (using _rootNavigatorKey)
    // ========================================================================

    // --- Auth ---
    GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const Login()),
    GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const Register()),
    GoRoute(
      path: '/otp',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final email = state.extra as String?;
        if (email == null || email.isEmpty) {
          debugPrint("Router Error: [/otp] Email missing in extra data.");

          return const Scaffold(
              body: Center(
                  child: Text("Error: Email missing for OTP verification.")));
        }
        return OtpInputScreen(email: email);
      },
    ),
    GoRoute(
        path: '/forgot-password-email',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ForgotPasswordEmailLink()),
    GoRoute(
        path: '/reset-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ForgotPassword()),

    // --- Chat & Video Call (Full Screen) ---
    GoRoute(
        path: '/chat/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/chat/consultation',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final params = state.extra as Map<String, String>?;
        if (params == null ||
            !params.containsKey('consultationId') ||
            !params.containsKey('userName') ||
            !params.containsKey('userRole') ||
            !params.containsKey('recipientName') ||
            !params.containsKey('doctorName') ||
            !params.containsKey('patientName') ||
            !params.containsKey('doctorId') ||
            !params.containsKey('patientId')) {
          debugPrint(
              "Router Error: [/chat/consultation] Missing required parameters in extra data. Received: $params");
          return const Scaffold(
              body: Center(
                  child: Text("Error: Chat details missing or incomplete.")));
        }

        return ChatScreen(
          consultationId: params['consultationId']!,
          userName: params['userName']!,
          userRole: params['userRole']!,
          recipientName: params['recipientName']!,
          doctorName: params['doctorName']!,
          patientName: params['patientName']!,
          doctorId: params['doctorId']!,
          patientId: params['patientId']!,
        );
      },
    ),
    GoRoute(
      path: '/video-call',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final params = state.extra as Map<String, String>?;
        if (params == null ||
            !params.containsKey('appId') ||
            !params.containsKey('token') ||
            !params.containsKey('channelName')) {
          debugPrint(
              "Router Error: [/video-call] Missing required parameters in extra data.");
          return const Scaffold(
              body: Center(
                  child: Text(
                      "Error: Video call details missing or incomplete.")));
        }
        return DoctorConsultation(
          appId: params['appId']!,
          token: params['token']!,
          channelName: params['channelName']!,
        );
      },
    ),

    // --- Patient Appointment Flow (Full Screen Steps) ---
    GoRoute(
      path: '/patient/appointment/confirm',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final params = state.extra as Map<String, dynamic>?;
        if (params == null) {
          debugPrint(
              "Router Error: [/patient/appointment/confirm] Missing extra data.");
          return const Scaffold(
              body: Center(child: Text("Error: Appointment data missing.")));
        }

        return AppointmentConfirmationPage(
          name: params['name'] as String? ?? 'N/A',
          age: params['age'] as String? ?? 'N/A',
          gender: params['gender'] as String? ?? 'N/A',
          date: params['date'] as String? ?? 'N/A',
          time: params['time'] as String? ?? 'N/A',
          doctor: params['doctor'] as String? ?? 'N/A',
          problem: params['problem'] as String? ?? 'N/A',
          onConfirm: params['onConfirm'] as VoidCallback? ?? () {},
        );
      },
    ),
    GoRoute(
      path: '/patient/appointment/history/details',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final params = state.extra as Map<String, dynamic>?;
        if (params == null) {
          debugPrint(
              "Router Error: [/patient/appointment/history/details] Missing extra data.");
          return const Scaffold(
              body: Center(child: Text("Error: Appointment details missing.")));
        }

        return AppointmentDetailsPage(
          doctorName: params['doctorName']?.toString() ?? 'N/A',
          specialty: params['specialty']?.toString() ?? 'N/A',
          appointmentDate: params['appointmentDate']?.toString() ?? 'N/A',
          appointmentTime: params['appointmentTime']?.toString() ?? 'N/A',
        );
      },
    ),
    GoRoute(
        path: '/patient/appointment/history/cancel-form',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final appointmentId = state.extra as String?;
          if (appointmentId == null || appointmentId.isEmpty) {
            debugPrint(
                "Router Error: [/patient/appointment/history/cancel-form] Missing appointmentId.");
            return const Scaffold(
                body: Center(child: Text("Error: Appointment ID missing.")));
          }
          return CancelAppointmentPage();
        }),
    GoRoute(
        path: '/patient/appointment/history/review2',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>?;
          if (params == null) {
            debugPrint(
                "Router Error: [/patient/appointment/history/review2] Missing parameters.");
            return const Scaffold(
                body: Center(child: Text("Error: Review details missing.")));
          }
          return ReviewPage2();
        }),
    GoRoute(
      path: '/payment', // Or your chosen path for payment
      parentNavigatorKey:
          _rootNavigatorKey, // Decide if it needs the shell or not
      builder: (context, state) {
        final appointmentId = state.extra as String?;
        if (appointmentId == null || appointmentId.isEmpty) {
          debugPrint(
              "Router Error: [/payment] Appointment ID missing in extra data.");
          // Return an error page or navigate back
          return const Scaffold(
              body: Center(
                  child:
                      Text("Error: Appointment ID is required for payment.")));
        }
        // Pass the received ID to your PaymentHomePage
        return PaymentHomePage(appointmentId: appointmentId);
      },
    ),

    // --- Health Record Add/Edit (Full Screen) ---
    GoRoute(
      path: '/patient/health-record/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddReportScreen(),
    ),
    GoRoute(
      path: '/patient/health-record/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final record = state.extra as Map<String, dynamic>?;
        if (record == null) {
          debugPrint(
              "Router Error: [/patient/health-record/edit] Missing record data in extra.");
          return const Scaffold(
              body:
                  Center(child: Text("Error: Record data missing for edit.")));
        }
        return AddReportScreen(existingRecord: record);
      },
    ),

    // --- Medication Reminder Details (Full Screen) ---
    GoRoute(
      path: '/medication-reminder/details',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final params = state.extra as Map<String, dynamic>?;
        if (params == null) {
          debugPrint(
              "Router Error: [/medication-reminder/details] Missing extra data.");
          return const Scaffold(
              body: Center(child: Text("Error: Pill details missing.")));
        }

        return PillDetails(
          id: params['id']?.toString() ?? '',
          name: params['name']?.toString() ?? 'N/A',
          details: params['details']?.toString() ?? '',
          duration: params['duration'] as int? ?? 0,
          takenDays: params['takenDays'] as int? ?? 0,
        );
      },
    ),

    // --- Emergency Flow (Full Screen) ---
    GoRoute(
        path: '/emergency-assistance/connecting',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ConnectingDocPage()),

    GoRoute(
        path: '/hospitals/connecting',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ConnectingDocPage()),

    GoRoute(
        path: '/pharmacies/connecting',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ConnectingDocPage()),

    // --- Profile Editing & Settings (Full Screen for both roles) ---
    GoRoute(
      // Patient - Edit Profile
      path: '/patient/profile/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final Map<String, dynamic>? args = state.extra as Map<String, dynamic>?;
        final Map<String, dynamic>? patientData =
            args?['patientData'] as Map<String, dynamic>?;
        final VoidCallback onProfileUpdated =
            args?['onProfileUpdated'] as VoidCallback? ?? () {};

        if (patientData == null) {
          debugPrint(
              "Router Error: [/patient/profile/edit] Missing patientData in extra map.");
          return const Scaffold(
              body: Center(
                  child: Text("Error: Patient data missing for editing.")));
        }
        return PatientEditProfilePage(
            patientData: patientData, onProfileUpdated: onProfileUpdated);
      },
    ),
    GoRoute(
        // Patient - Settings Root & Sub-routes
        path: '/patient/profile/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PatientSettingsPage(),
        routes: <RouteBase>[
          GoRoute(
              path: 'notifications',
              builder: (context, state) =>
                  const PatientNotifications.NotificationsPage()),
          GoRoute(
              path: 'change-password',
              builder: (context, state) =>
                  const PatientChangePassword.ChangePasswordScreen()),
          GoRoute(
              path: 'delete-account',
              builder: (context, state) =>
                  const PatientDeleteAccount.DeleteAccountScreen()),
        ]),
    GoRoute(
      // Patient - View Doctor Profile (Stand-alone Page)
      path: '/patient/doctors/profile_view',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final doctorId = state.extra as String?;
        debugPrint(
            "Router [/patient/doctors/profile_view]: Received extra: $doctorId");

        if (doctorId == null || doctorId.isEmpty) {
          debugPrint(
              "Router Error: [/patient/doctors/profile_view] Doctor ID is null or empty in extra data.");
          return Scaffold(
              appBar: AppBar(title: const Text("Error")),
              body:
                  const Center(child: Text("Error: Doctor ID not provided.")));
        }

        debugPrint("Router: Navigating to DoctorProfile with ID: $doctorId");
        return DoctorProfile(doctorId: doctorId);
      },
    ),
    GoRoute(
      // Doctor - Edit Profile
      path: '/doctor/profile/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final Map<String, dynamic>? args = state.extra as Map<String, dynamic>?;
        final Map<String, dynamic>? doctorData =
            args?['doctorData'] as Map<String, dynamic>?;
        final String? doctorId =
            args?['doctorId'] as String?; // Extract doctorId
        final VoidCallback onProfileUpdated =
            args?['onProfileUpdated'] as VoidCallback? ?? () {};

        if (doctorData == null || doctorId == null || doctorId.isEmpty) {
          // Check doctorId too
          debugPrint(
              "Router Error: [/doctor/profile/edit] Missing doctorData or doctorId in extra map. Args: $args");
          return const Scaffold(
              body: Center(
                  child:
                      Text("Error: Doctor data or ID missing for editing.")));
        }
        // Use the renamed import
        return DoctorEditProfile.EditProfilePage(
            doctorId: doctorId, // Pass the doctorId
            doctorData: doctorData,
            onProfileUpdated: onProfileUpdated);
      },
    ),
    GoRoute(
        // Doctor - Settings Root & Sub-routes
        path: '/doctor/profile/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DoctorSettings.settings(),
        routes: <RouteBase>[
          GoRoute(
              path: 'notifications',
              builder: (context, state) =>
                  const DoctorNotifications.NotificationsPage()),
          GoRoute(
              path: 'change-password',
              builder: (context, state) =>
                  const DoctorChangePassword.ChangePasswordScreen()),
          GoRoute(
              path: 'delete-account',
              builder: (context, state) =>
                  const DoctorDeleteAccount.DeleteAccountScreen()),
          GoRoute(
              path: 'terms',
              builder: (context, state) => const DoctorTerms.TermsPage()),
          GoRoute(
              path: 'privacy',
              builder: (context, state) => const DoctorPrivacy.PrivacyPage()),
        ]),
    GoRoute(
      path:
          '/chatbot', // Path: /chatbot (relative to root, but handled by Shell)
      builder: (context, state) => ChatBotScreen(),
    ),
    GoRoute(
      path: '/doctor/consultation-history',
      parentNavigatorKey: _rootNavigatorKey, // Place outside shell
      builder: (context, state) => const DoctorConsultationHistoryPage(),
    ),

    GoRoute(
      // Doctor - Inbox Message Details
      path: '/doctor/inbox/message-details',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final params = state.extra as Map<String, dynamic>?;
        if (params == null ||
            params['sender'] == null ||
            params['messages'] == null) {
          debugPrint(
              "Router Error: [/doctor/inbox/message-details] Missing sender or messages in extra data.");
          return const Scaffold(
              body: Center(
                  child:
                      Text("Error: Message details missing or incomplete.")));
        }

        final messagesList =
            List<Map<String, dynamic>>.from(params['messages']!);

        return MessageDetailPage(
          sender: params['sender']!,
          messages: messagesList,
        );
      },
    ),

    // --- Doctor Patient Management Routes (Outside Shell) ---
    GoRoute(
      path: '/doctor/patient-detail/:patientId', // Use path parameter
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final patientId = state.pathParameters['patientId'];
        final extra = state.extra as Map<String, dynamic>?;
        final doctorId = extra?['doctorId'] as String?;

        if (patientId == null ||
            patientId.isEmpty ||
            doctorId == null ||
            doctorId.isEmpty) {
          debugPrint(
              "Router Error: [/doctor/patient-detail/:patientId] Missing patientId or doctorId.");
          return const Scaffold(
              body:
                  Center(child: Text("Error: Patient or Doctor ID missing.")));
        }
        return DoctorPatientDetailPage(
            patientId: patientId, doctorId: doctorId);
      },
    ),
    GoRoute(
      path: '/doctor/patient-note/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final patientId = extra?['patientId'] as String?;
        final doctorId = extra?['doctorId'] as String?;

        if (patientId == null ||
            patientId.isEmpty ||
            doctorId == null ||
            doctorId.isEmpty) {
          debugPrint(
              "Router Error: [/doctor/patient-note/add] Missing patientId or doctorId.");
          return const Scaffold(
              body: Center(
                  child: Text(
                      "Error: Patient or Doctor ID missing for adding note.")));
        }
        // Navigate to AddEditNotePage without noteData for adding
        return AddEditNotePage(patientId: patientId, doctorId: doctorId);
      },
    ),
    GoRoute(
      path:
          '/doctor/patient-note/edit/:noteId', // Use path parameter for noteId
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final noteId = state.pathParameters['noteId'];
        final extra = state.extra as Map<String, dynamic>?;
        final noteData = extra?['noteData'] as Map<String, dynamic>?;
        final patientId = extra?['patientId'] as String?;
        final doctorId = extra?['doctorId'] as String?;

        if (noteId == null ||
            noteId.isEmpty ||
            noteData == null ||
            patientId == null ||
            doctorId == null) {
          debugPrint(
              "Router Error: [/doctor/patient-note/edit/:noteId] Missing noteId, noteData, patientId, or doctorId.");
          return const Scaffold(
              body: Center(
                  child: Text("Error: Note details missing for editing.")));
        }
        // Navigate to AddEditNotePage with noteData for editing
        return AddEditNotePage(
            patientId: patientId, doctorId: doctorId, noteData: noteData);
      },
    ),

    // --- Health Articles Routes (Outside Shell for Detail/Create/Edit) ---
    GoRoute(
      path: '/patient/articles/:articleId', // Patient view detail
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final articleId = state.pathParameters['articleId'];
        if (articleId == null || articleId.isEmpty) {
          return const Scaffold(
              body: Center(child: Text("Error: Article ID missing.")));
        }
        return PatientArticleDetailPage(articleId: articleId);
      },
    ),
    GoRoute(
      path: '/doctor/articles/create', // Doctor create article
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          const CreateEditArticlePage(), // No initial data needed
    ),
    GoRoute(
      path: '/doctor/articles/edit/:articleId', // Doctor edit article
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final articleId = state.pathParameters['articleId']; // Get ID from path
        final articleData =
            state.extra as Map<String, dynamic>?; // Get data passed via extra
        if (articleId == null || articleId.isEmpty || articleData == null) {
          debugPrint(
              "Router Error: [/doctor/articles/edit/:articleId] Missing articleId or articleData.");
          return const Scaffold(
              body: Center(
                  child: Text("Error: Article details missing for editing.")));
        }
        // Pass existing data to the edit page
        return CreateEditArticlePage(articleData: articleData);
      },
    ),

    // ========================================================================
    // ShellRoute for Routes INSIDE the MainLayout (using _shellNavigatorKey)
    // ========================================================================
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: <RouteBase>[
        // --- Core ---

        GoRoute(path: '/home', builder: (context, state) => const HomePage()),

        // --- Patient Routes (Inside Shell) ---
        GoRoute(
            path: '/p_dashboard',
            builder: (context, state) => PatientDashboard.DashboardScreen()),
        GoRoute(
            path: '/patient/profile',
            builder: (context, state) => PatientProfilePage()),
        GoRoute(
            path: '/patient/doctors/search',
            builder: (context, state) => const DoctorProfilesPage()),

        GoRoute(
            path: '/patient/doctors/az',
            builder: (context, state) {
              final id = state.extra as String? ?? "d_pid";
              return AZScreen(patientId: id);
            }),
        GoRoute(
            path: '/patient/doctors/favorites',
            builder: (context, state) {
              final id = state.extra as String? ?? "d_pid";
              return FavoriteScreen(patientId: id);
            }),
        GoRoute(
            path: '/patient/doctors/male',
            builder: (context, state) {
              final id = state.extra as String? ?? "d_pid";
              return MaleDoctorScreen(patientId: id);
            }),
        GoRoute(
            path: '/patient/doctors/female',
            builder: (context, state) {
              final id = state.extra as String? ?? "d_pid";
              return FemaleDoctorScreen(patientId: id);
            }),

        GoRoute(
          path: '/patient/appointment/schedule',
          builder: (context, state) {
            final doctorInfo = state.extra as Map<String, dynamic>?;
            debugPrint(
                "Router [/patient/appointment/schedule]: Received extra: $doctorInfo");
            return AppointmentSchedulePage(doctorInfo: doctorInfo);
          },
        ),

        GoRoute(
          path: '/patient/appointment/history',
          builder: (context, state) => const AppointmentHistoryPage(),
        ),
        GoRoute(
            path: '/patient/health-record',
            builder: (context, state) => const HealthRecordScreen()),
        GoRoute(
            path: '/patient/articles',
            builder: (context, state) => const PatientArticleListPage()),

        // --- Doctor Routes (Inside Shell) ---
        GoRoute(
            path: '/d_dashboard',
            builder: (context, state) =>
                DoctorDashboardEntry.DashboardScreen()),
        GoRoute(
            path: '/doctor/profile',
            builder: (context, state) => DoctorProfileEntry.ProfilePage()),
        GoRoute(
            path: '/doctor/appointment/schedule',
            builder: (context, state) => const DAppointmentManagementPage()),
        GoRoute(
            path: '/doctor/availability',
            builder: (context, state) => const DoctorAvailabilityPage()),
        GoRoute(
            path: '/doctor/prescription-tool',
            builder: (context, state) => const PrescriptionSelectorPage()),
        GoRoute(
            path: '/doctor/patient-list',
            builder: (context, state) => const DoctorPatientListPage()),
        GoRoute(
            path: '/doctor/overview',
            builder: (context, state) => const OverviewPage()),
        GoRoute(
            path: '/doctor/inbox',
            builder: (context, state) => const InboxPage()),
        GoRoute(
            path: '/doctor/earnings',
            builder: (context, state) =>
                const DoctorDashboardEarnings.EarningsPage()),
        // --- FIX: Use pageBuilder with ValueKey for /doctor/articles ---
        GoRoute(
          path: '/doctor/articles',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DoctorMyArticlesPage(),
            key: ValueKey('doctor_articles_list'), // Unique key
          ),
          // builder: (context, state) => const DoctorMyArticlesPage(), // Original builder
        ),
        // --- END FIX ---

        // --- Shared Features (Inside Shell) ---
        GoRoute(
            path: '/teleconsultation',
            builder: (context, state) => const IndexPage()),
        GoRoute(
            path: '/notifications',
            builder: (context, state) {
              final params = state.extra as Map<String, String>?;
              final receiverId = params?['receiverId'];
              final receiverType = params?['receiverType'];
              if (receiverId == null || receiverType == null) {
                debugPrint(
                    "Router Error: [/notifications] Missing receiverId or receiverType in extra data.");

                return const NotificationsScreen(
                    receiverId: 'default_user', receiverType: 'patient');
              }
              return NotificationsScreen(
                  receiverId: receiverId, receiverType: receiverType);
            }),
        //GoRoute( path: '/chatbot', builder: (context, state) => ChatBotScreen()),
        GoRoute(
            path: '/symptom-tracker',
            builder: (context, state) => const SymptomTrackerScreen()),
        GoRoute(
            path: '/medication-reminder',
            builder: (context, state) => Medication_Reminder(),
            routes: <RouteBase>[
              GoRoute(
                  path: 'vaccination',
                  builder: (context, state) => Vaccination_Reminder()),
            ]),
        GoRoute(
            path: '/emergency-assistance',
            builder: (context, state) => EmergencyAssistantPage()),
        GoRoute(
            path: '/hospitals', builder: (context, state) => HospitalScreen()),

        GoRoute(
            path: '/pharmacies', builder: (context, state) => PharmacyScreen()),
        GoRoute(
            path: '/help-center',
            builder: (context, state) => const HelpCentrePage()),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text("Page Not Found")),
    body: Center(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Error: Route not found for "${state.uri}"\n${state.error?.message ?? ''}',
        textAlign: TextAlign.center,
      ),
    )),
  ),
);

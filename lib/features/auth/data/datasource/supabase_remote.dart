import 'package:medical_app/core/errors/common/expection.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteSource {
  Session? get isActiveUser;

  Future<UserModel> signUpPatient({
    required String phone,
    required String gender,
    required String email,
    required String password,
    required String dob,
    required String firstname,
    required String lastname,
  });

  Future<void> requestEmailOtp(String email);

  Future<UserModel> verifyEmailOtp(String email, String otp);

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel?> getIsActiveUser();

  Future<void> signOut();

  Future<void> insertPatientProfile({
    required String uid,
    required String firstname,
    required String lastname,
    required String phone,
    required String dob,
    required String gender,
    required String email,
  });
}

class AuthRemoteSourceImp implements AuthRemoteSource {
  final SupabaseClient supabaseClient;

  AuthRemoteSourceImp(this.supabaseClient);

  @override
  Future<UserModel> signUpPatient({
    required String phone,
    required String gender,
    required String email,
    required String password,
    required String dob,
    required String firstname,
    required String lastname,
  }) async {
    try {
      // Step 1: Sign up the user using Supabase Auth
      final authResponse = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {
          'phone': phone,
          'dob': dob,
          'role': 'patient',
          'firstname': firstname,
          'lastname': lastname,
          'gender': gender,
        },
      );

      if (authResponse.user == null) {
        throw ServerException("User is not available after signup");
      }

      // Step 2: Generate the Patient ID based on existing records
      final latestPatient = await supabaseClient
          .from('patients')
          .select('patient_id')
          .order('patient_id', ascending: false)
          .limit(1)
          .maybeSingle();

      int nextNumber = 1;
      if (latestPatient != null && latestPatient['patient_id'] != null) {
        final latestPatientId = latestPatient['patient_id'] as String;
        final numericPart = int.tryParse(latestPatientId.replaceAll('PAT', '')) ?? 0;
        nextNumber = numericPart + 1;
      }

      final newPatientId = 'PAT${nextNumber.toString().padLeft(3, '0')}';

      // Step 3: Insert the new patient record into the database using email
      final insertResponse = await supabaseClient.from('patients').insert([
        {
          'patient_id': newPatientId,
          'email': email, // Using email instead of user_id
          'first_name': firstname,
          'last_name': lastname,
          'phone_number': phone,
          'date_of_birth': dob,
          'gender': gender,
        }
      ]); // execute() provides detailed response

      // Debug: Print the insert response for better debugging
      print("Insert response: ${insertResponse.data}");

      // Return the UserModel with role 'patient'
      return UserModel.fromJson(authResponse.user!.toJson()).copyWith(role: 'patient');
    } catch (e) {
      // Log the error and throw ServerException with error details
      print('Signup failed: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> requestEmailOtp(String email) async {
    try {
      await supabaseClient.auth.signInWithOtp(email: email);
    } catch (e) {
      throw ServerException('Error sending OTP: $e');
    }
  }

  @override
  Future<UserModel> verifyEmailOtp(String email, String otp) async {
    try {
      final res = await supabaseClient.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.signup,
      );

      if (res.user == null) {
        throw const ServerException("Invalid OTP or email not verified");
      }

      return UserModel.fromJson(res.user!.toJson());
    } catch (e) {
      throw ServerException('OTP verification failed: $e');
    }
  }

  @override
  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        throw const ServerException("Invalid credentials");
      }

      if (res.user!.emailConfirmedAt == null) {
        throw const ServerException(
          "Please verify your email before logging in.",
        );
      }

      // Move email declaration here to avoid the 'potentially unassigned' error
      final String? userEmail = res.user!.email;

      if (userEmail == null) {
        throw const ServerException("Email is null");
      }

      // Proceed with querying the user based on email
      final patientRes = await supabaseClient
          .from('patients')
          .select()
          .eq('email', userEmail)
          .maybeSingle();

      if (patientRes != null) {
        return UserModel.fromJson(res.user!.toJson()).copyWith(role: 'patient');
      }

      // Find doctor by email (in case of doctor login)
      final doctorRes = await supabaseClient
          .from('doctors')
          .select()
          .eq('email', userEmail)
          .maybeSingle();

      if (doctorRes != null) {
        return UserModel.fromJson(res.user!.toJson()).copyWith(role: 'doctor');
      }

      throw const ServerException(
        "User role not assigned. Please contact support.",
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Session? get isActiveUser => supabaseClient.auth.currentSession;

  @override
  Future<UserModel?> getIsActiveUser() async {
    try {
      if (isActiveUser != null) {
        final sessionp = await supabaseClient
            .from('patients')
            .select()
            .eq('id', isActiveUser!.user.id)
            .maybeSingle();

        final sessiond = await supabaseClient
            .from('doctors')
            .select()
            .eq('id', isActiveUser!.user.id)
            .maybeSingle();

        // If the user is found in the patient table, return UserModel from sessionp
        if (sessionp != null) {
          return UserModel.fromJson(sessionp).copyWith(
            email: isActiveUser!.user.email,
          );
        }

        // If the user is found in the doctor table, return UserModel from sessiond
        if (sessiond != null) {
          return UserModel.fromJson(sessiond).copyWith(
            email: isActiveUser!.user.email,
          );
        }

        // If no user is found in either table, throw an error
        throw const ServerException(
            "User not found in both patient and doctor databases.");
      }
      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException("Failed to sign out: ${e.toString()}");
    }
  }

  @override
  Future<void> insertPatientProfile({
    required String uid,
    required String firstname,
    required String lastname,
    required String phone,
    required String dob,
    required String gender,
    required String email,
  }) async {
    try {
      String newPatientId = '';
      bool isUnique = false;
      int nextNumber = 1;

      while (!isUnique) {
        newPatientId = 'PAT${nextNumber.toString().padLeft(3, '0')}';

        final response = await supabaseClient
            .from('patients')
            .select('patient_id')
            .eq('patient_id', newPatientId)
            .maybeSingle();

        if (response == null) {
          isUnique = true;
        } else {
          nextNumber++;
        }
      }

      final insertResponse = await supabaseClient.from('patients').insert({
        'patient_id': newPatientId,
        'first_name': firstname,
        'last_name': lastname,
        'phone_number': phone,
        'date_of_birth': dob,
        'gender': gender,
        'email': email,
      });

      if (insertResponse.error != null) {
        throw ServerException(insertResponse.error!.message);
      }

      print('Patient profile inserted successfully with ID: $newPatientId');
    } catch (e) {
      throw ServerException('Failed to insert patient profile: $e');
    }
  }
}

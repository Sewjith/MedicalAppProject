import 'package:flutter/material.dart';
import 'package:medical_app/features/doctor-search/data/repos/dummy_doctor_profiles.dart';
import 'package:medical_app/features/doctor-search/domain/usecases/get_doctors_usecase.dart';
import 'package:medical_app/features/doctor-search/presentation/widgets/profile_widget.dart';

class DoctorProfilesPage extends StatelessWidget {
  const DoctorProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final doctors = DoctorsList();
    final doctorDetails = GetDoctorsUsecase(doctors);
    final profiles = doctorDetails.call();
    return Scaffold(
      body: ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          return ProfileWidget(profile: profiles[index]);// currently working with dummy data needs to be chnaged for backend implementation for data fetching
        },
      ),
    );
  }
}

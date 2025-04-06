import 'package:flutter/material.dart';
import 'package:medical_app/features/doctor-search/data/repos/dummy_doctor_profiles.dart';
import 'package:medical_app/features/doctor-search/domain/entities/doctor_profiles.dart';
import 'package:medical_app/features/doctor-search/domain/usecases/get_doctors_usecase.dart';
import 'package:medical_app/features/doctor-search/presentation/widgets/profile_widget.dart';
import 'package:medical_app/features/doctor-search/presentation/widgets/searchbar_widget.dart';

class DoctorProfilesPage extends StatefulWidget {
  const DoctorProfilesPage({Key? key}) : super(key: key);

  @override
  State<DoctorProfilesPage> createState() => _DoctorProfilesPageState();
}

class _DoctorProfilesPageState extends State<DoctorProfilesPage> {
  late TextEditingController _controller;
  late List<DoctorProfiles> profiles;
  List<DoctorProfiles> _searchedDoctor = [];
  String searchText = "";

  @override
  void initState() {
    final doctors = DoctorsList();
    final doctorDetails = GetDoctorsUsecase(doctors);
    _controller = TextEditingController();
    profiles = doctorDetails.call();
    _searchedDoctor = profiles;
    super.initState();
  }

  void _onChanged(String value) {
    setState(() {
      searchText = value;
      filteredList();
    });
  }

  void filteredList() {
    if (searchText.isEmpty) {
      _searchedDoctor = profiles;
    } else {
      _searchedDoctor = profiles
          .where((profile) =>
              profile.firstName
                  .toLowerCase()
                  .contains(searchText.toLowerCase()) ||
              profile.lastName.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        SearchbarWidget(controller: _controller, onChanged: _onChanged),
        Expanded(
          child: ListView.builder(
            itemCount: _searchedDoctor.length,
            itemBuilder: (context, index) {
              return ProfileWidget(
                  profile: _searchedDoctor[
                      index]); // currently working with dummy data needs to be chnaged for backend implementation for data fetching
            },
          ),
        ),
      ],
    ));
  }
}

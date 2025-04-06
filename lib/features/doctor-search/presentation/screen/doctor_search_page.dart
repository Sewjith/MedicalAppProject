import 'package:flutter/material.dart';
import 'package:medical_app/features/doctor-search/data/source/supabase_remote_doctors.dart';
import 'package:medical_app/features/doctor-search/domain/entities/doctor_profiles.dart';
import 'package:medical_app/features/doctor-search/presentation/widgets/profile_widget.dart';
import 'package:medical_app/features/doctor-search/presentation/widgets/searchbar_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorProfilesPage extends StatefulWidget {
  const DoctorProfilesPage({super.key});

  @override
  State<DoctorProfilesPage> createState() => _DoctorProfilesPageState();
}

class _DoctorProfilesPageState extends State<DoctorProfilesPage> {
  late TextEditingController _controller;
  late List<DoctorProfiles> profiles = [];
  List<DoctorProfiles> _searchedDoctor = [];
  String searchText = "";
  final DoctorListRemoteSource doctorListRemoteSource =
      DoctorListRemoteSourceImp(Supabase.instance.client);

  @override
  void initState() {
    _controller = TextEditingController();
    _fetchDoctorData();
    super.initState();
  }

  void _fetchDoctorData() async {
    try {
      final fetchedProfiles = await doctorListRemoteSource.getAllDoctors();
      setState(() {
        profiles = fetchedProfiles;
        _searchedDoctor = profiles;
      });
    } catch (e) {
      print("Error fetching doctor profiles: $e");
    }
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
        appBar: AppBar(
          title: Text('Doctor Profiles'),
        ),
        body: Column(
          children: [
            SearchbarWidget(controller: _controller, onChanged: _onChanged),
            Expanded(
              child: ListView.builder(
                itemCount: _searchedDoctor.length,
                itemBuilder: (context, index) {
                  return ProfileWidget(profile: _searchedDoctor[index]);
                },
              ),
            ),
          ],
        ));
  }
}

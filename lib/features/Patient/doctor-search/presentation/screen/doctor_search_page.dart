import 'package:flutter/material.dart';
import 'package:medical_app/features/Patient/doctor-search/data/model/doctor_list_model.dart';
import 'package:medical_app/features/Patient/doctor-search/data/source/supabase_remote_doctors.dart';
import 'package:medical_app/features/Patient/doctor-search/presentation/widgets/profile_widget.dart';
import 'package:medical_app/features/Patient/doctor-search/presentation/widgets/searchbar_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorProfilesPage extends StatefulWidget {
  const DoctorProfilesPage({Key? key}) : super(key: key);

  @override
  State<DoctorProfilesPage> createState() => _DoctorProfilesPageState();
}

class _DoctorProfilesPageState extends State<DoctorProfilesPage> {
  late TextEditingController _controller;
  late List<DoctorListModel> profiles = [];
  List<DoctorListModel> _searchedDoctor = [];
  String searchText = "";

  bool _isLoading = true;
  String? _errorMessage;

  final DoctorListRemoteSource doctorListRemoteSource =
      DoctorListRemoteSourceImp(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _fetchDoctorData();
  }

  void _fetchDoctorData() async {
    try {
      // Fetching the doctor profiles from Supabase
      final fetchedProfiles = await doctorListRemoteSource.getAllDoctors();

      setState(() {
        profiles = fetchedProfiles;
        _searchedDoctor = profiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching doctor profiles.";
        _isLoading = false;
      });
    }
  }

  void _onChanged(String value) {
    searchText = value;
    filteredList();
  }

  void filteredList() {
    setState(() {
      if (searchText.isEmpty) {
        _searchedDoctor = profiles;
      } else {
        _searchedDoctor = profiles
            .where((profile) =>
                profile.firstName.toLowerCase().contains(searchText.toLowerCase()) ||
                profile.lastName.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profiles'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    // Search Bar
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
                ),
    );
  }
}

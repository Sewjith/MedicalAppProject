import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
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
  List<Map<String, dynamic>> _searchedDoctors = [];
  String _searchText = "";
  Timer? _debounce;

  bool _isLoading = false;
  String? _errorMessage;

  final DoctorListRemoteSource _doctorListRemoteSource =
      DoctorListRemoteSourceImp(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchDoctors(query);
    });
  }

  Future<void> _searchDoctors(String query) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchText = query;
    });

    try {
      final results = await _doctorListRemoteSource.searchDoctors(query);
      if (!mounted) return;
      setState(() {
        _searchedDoctors = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Error fetching doctors: ${e.toString()}";
        _searchedDoctors = [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: const Text('Find Doctors'),
         backgroundColor: AppPallete.primaryColor,
         foregroundColor: AppPallete.whiteColor,
         elevation: 1,
       ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchbarWidget(
              controller: _controller,
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                      ))
                    : _searchedDoctors.isEmpty
                       ? Center(
                            child: Padding(
                               padding: const EdgeInsets.all(16.0),
                               child: Text(
                                  _searchText.isEmpty
                                      ? 'Start typing to search for doctors by name or specialty.'
                                      : 'No doctors found matching "$_searchText".',
                                   style: TextStyle(fontSize: 16, color: AppPallete.greyColor),
                                   textAlign: TextAlign.center,
                               ),
                            )
                         )
                       : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            itemCount: _searchedDoctors.length,
                            itemBuilder: (context, index) {
                              // Pass the Map directly to ProfileWidget
                              return ProfileWidget(
                                profileData: _searchedDoctors[index],
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
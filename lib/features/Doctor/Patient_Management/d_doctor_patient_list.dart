import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For network images
import 'd_patient_notes_db.dart'; // Import the new DB service

class DoctorPatientListPage extends StatefulWidget {
  const DoctorPatientListPage({Key? key}) : super(key: key);

  @override
  _DoctorPatientListPageState createState() => _DoctorPatientListPageState();
}

class _DoctorPatientListPageState extends State<DoctorPatientListPage> {
  final DoctorPatientNotesDB _db = DoctorPatientNotesDB();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _doctorId; // To store the logged-in doctor's ID

  @override
  void initState() {
    super.initState();
    _initializeDoctorIdAndLoadPatients();
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch doctor ID and load associated patients
  Future<void> _initializeDoctorIdAndLoadPatients() async {
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserLoggedIn && userState.user.role == 'doctor') {
      _doctorId = userState.user.uid;
      if (_doctorId != null) {
        _loadPatients();
      } else {
         if (mounted) {
           setState(() {
             _isLoading = false;
             _errorMessage = "Could not retrieve Doctor ID.";
           });
         }
      }
    } else {
       if (mounted) {
         setState(() {
           _isLoading = false;
           _errorMessage = "User is not logged in as a doctor.";
         });
       }
    }
  }

  // Load patients associated with the current doctor
  Future<void> _loadPatients() async {
    if (_doctorId == null || !mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final patientsData = await _db.getDoctorPatientsList(_doctorId!);
      if (!mounted) return;
      setState(() {
        _patients = patientsData;
        _filterPatients(); // Apply filter immediately
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Failed to load patients: ${e.toString().replaceFirst('Exception: ', '')}';
        _patients = [];
        _filteredPatients = [];
      });
    }
  }

  // Filter patients based on search query
  void _filterPatients() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = List.from(_patients); // Reset to full list
      } else {
        _filteredPatients = _patients.where((patient) {
          final firstName = patient['first_name']?.toString().toLowerCase() ?? '';
          final lastName = patient['last_name']?.toString().toLowerCase() ?? '';
          final fullName = '$firstName $lastName';
          return fullName.contains(query);
        }).toList();
      }
    });
  }

  // Navigate to patient detail page
  void _navigateToPatientDetail(String patientId) {
     // Pass patientId and doctorId to the detail page
    context.push('/doctor/patient-detail/$patientId', extra: {'doctorId': _doctorId});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppPallete.whiteColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppPallete.primaryColor),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/d_dashboard'); // Fallback
            }
          },
        ),
        title: const Text(
          'My Patients',
          style: TextStyle(
            color: AppPallete.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                hintStyle: const TextStyle(color: AppPallete.greyColor),
                prefixIcon:
                    const Icon(Icons.search, color: AppPallete.greyColor),
                filled: true,
                fillColor: AppPallete.whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppPallete.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppPallete.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppPallete.primaryColor, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
            const SizedBox(height: 16),
            // Patient List Area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Text(_errorMessage!,
                              style: const TextStyle(color: Colors.red)))
                      : _filteredPatients.isEmpty
                          ? Center(
                              child: Text(_searchController.text.isEmpty
                                  ? 'No patients found.'
                                  : 'No results for "${_searchController.text}"'))
                          : RefreshIndicator(
                              onRefresh: _loadPatients,
                              child: ListView.builder(
                                itemCount: _filteredPatients.length,
                                itemBuilder: (context, index) {
                                  final patient = _filteredPatients[index];
                                  return _buildPatientCard(patient);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build individual patient card
  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final patientName =
        '${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}'.trim();
    final avatarUrl = patient['avatar_url'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: () => _navigateToPatientDetail(patient['id']),
        leading: CircleAvatar(
          backgroundColor: AppPallete.primaryColor.withOpacity(0.1),
          backgroundImage: avatarUrl != null
              ? CachedNetworkImageProvider(avatarUrl)
              : const AssetImage('assets/images/patient.jpeg') as ImageProvider, // Fallback asset
           onBackgroundImageError: (_, __) { debugPrint("Error loading patient image: $avatarUrl"); },
           child: avatarUrl == null ? Text(
             patientName.isNotEmpty ? patientName[0].toUpperCase() : '?',
             style: const TextStyle(fontWeight: FontWeight.bold, color: AppPallete.primaryColor),
           ) : null,
        ),
        title: Text(
          patientName.isEmpty ? 'Unknown Patient' : patientName,
          style: const TextStyle(
              color: AppPallete.textColor, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          "Age: ${patient['age'] ?? 'N/A'}, Gender: ${patient['gender'] ?? 'N/A'}",
          style: const TextStyle(color: AppPallete.greyColor),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            color: AppPallete.greyColor, size: 16),
      ),
    );
  }
}

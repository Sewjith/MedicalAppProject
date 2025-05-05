import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/Patient/doctor-search/data/source/supabase_remote_doctors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medical_app/core/errors/common/expection.dart';

class DoctorProfile extends StatefulWidget {
  final String doctorId;

  const DoctorProfile({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final DoctorListRemoteSource _doctorListRemoteSource =
      DoctorListRemoteSourceImp(Supabase.instance.client);

  Map<String, dynamic>? _doctorData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
     if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _doctorListRemoteSource.getDoctorProfileDetails(widget.doctorId);
      if (mounted) {
        setState(() {
          _doctorData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e is ServerException ? e.exception : e.toString();
        });
      }
    }
  }

  String _getProfileImageAsset(String? gender) {
    // This function already handles null gender safely
    final lowerGender = gender?.toLowerCase();
    if (lowerGender == 'female') {
      return 'assets/images/female_doctor.jpg'; // Ensure this asset exists
    } else {
      return 'assets/images/doctor.jpg'; // Ensure this asset exists
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Info', style: TextStyle(color: AppPallete.headings)),
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
               context.pop();
            } else {
               context.go('/patient/doctors/search');
            }
          },
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppPallete.primaryColor),
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)),
                ))
              : _doctorData == null
                  ? const Center(child: Text('Doctor details not found.'))
                  : _buildProfileContent(),
      bottomNavigationBar: _doctorData != null ? _buildActionButtons() : null,
    );
  }

  Widget _buildProfileContent() {
  
    final String firstName = _doctorData!['first_name'] ?? '';
    final String lastName = _doctorData!['last_name'] ?? '';
    final String title = _doctorData!['title'] ?? '';
    final String specialty = _doctorData!['specialty'] ?? 'N/A';
    final String gender = _doctorData!['gender'] ?? 'Unknown'; // Provide fallback

    final int experience = _doctorData!['years_of_experience'] ?? 0;
    final String description = (_doctorData!['description']?.isNotEmpty ?? false)
                             ? _doctorData!['description']
                             : 'No detailed profile information available.';
    final List<dynamic> qualificationsList = _doctorData!['qualifications'] ?? [];
    final List<dynamic> languagesList = _doctorData!['language'] ?? [];

    final String qualifications = (qualificationsList is List && qualificationsList.isNotEmpty)
                                 ? qualificationsList.whereType<String>().join(', ') // Filter for strings
                                 : 'Not specified';

    final String languages = (languagesList is List && languagesList.isNotEmpty)
                             ? languagesList.whereType<String>().join(', ') // Filter for strings
                             : 'Not specified';

    final String fullName = '$title $firstName $lastName'.trim();

    final String imageAssetPath = _getProfileImageAsset(gender == 'Unknown' ? null : gender);


    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(imageAssetPath),
                          backgroundColor: Colors.grey[200],
                           onBackgroundImageError: (exception, stackTrace) { // Add error handling
                              debugPrint("Error loading asset image $imageAssetPath: $exception");
                           },
                           child: null, // Explicitly null if background image is set
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName.isEmpty ? 'Doctor Profile' : fullName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppPallete.textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                specialty,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppPallete.primaryColor,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                               const SizedBox(height: 8),
                              if (experience > 0)
                                _buildInfoChip(Icons.star_border, '$experience Years Experience'),
                              if (languages.isNotEmpty && languages != 'Not specified') ...[
                                 const SizedBox(height: 4),
                                 _buildInfoChip(Icons.language, languages),
                              ]

                            ],
                          ),
                        ),
                      ],
                    ),
                      const Divider(height: 24, thickness: 1),
                       _buildDetailRow(Icons.school_outlined, 'Qualifications', qualifications),
                  ],
                ),
              ),
            ),
             const SizedBox(height: 20),
            _buildDetailSection('About Doctor', description),
          ],
        ),
      ),
    );
  }

   Widget _buildInfoChip(IconData icon, String text) {
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
       decoration: BoxDecoration(
          color: AppPallete.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
       ),
       child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             Icon(icon, size: 14, color: AppPallete.primaryColor),
             const SizedBox(width: 4),
             Flexible(
               child: Text(
                 text,
                 style: const TextStyle(fontSize: 13, color: AppPallete.primaryColor, fontWeight: FontWeight.w500),
                 overflow: TextOverflow.ellipsis,
               ),
             ),
          ],
       ),
     );
   }

   Widget _buildDetailRow(IconData icon, String title, String value) {

     final displayValue = value.isNotEmpty ? value : 'Not specified';
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 4.0),
       child: Row(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Icon(icon, color: AppPallete.primaryColor, size: 18),
           const SizedBox(width: 8),
           Text(
             '$title: ',
             style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppPallete.textColor),
           ),
           Expanded(
             child: Text(
               displayValue,
               style: const TextStyle(fontSize: 15, color: AppPallete.textColor),
             ),
           ),
         ],
       ),
     );
   }

   Widget _buildDetailSection(String title, String content) {
     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 4.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(
             title,
             style: const TextStyle(
               fontSize: 18,
               fontWeight: FontWeight.bold,
               color: AppPallete.primaryColor,
             ),
           ),
           const SizedBox(height: 8),
           Text(
             content, // Content already has a fallback
             style: const TextStyle(
               fontSize: 15,
               color: AppPallete.textColor,
               height: 1.4
             ),
             textAlign: TextAlign.justify,
           ),
           const SizedBox(height: 20),
         ],
       ),
     );
   }

    Widget _buildActionButtons() {
      if (_doctorData == null) return const SizedBox.shrink();

      final doctorName = '${_doctorData!['title'] ?? ''} ${_doctorData!['first_name'] ?? ''} ${_doctorData!['last_name'] ?? ''}'.trim();
      final doctorId = widget.doctorId;

      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
             color: Colors.white,
             boxShadow: [
                 BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                 ),
             ],
          ),
          child: ElevatedButton(
                onPressed: () {
                    debugPrint("Navigating to schedule. Passing extra: {'doctorId': $doctorId, 'doctorName': $doctorName}");
    
                    context.go(
                       '/patient/appointment/schedule',
                        extra: {
                            'doctorId': doctorId,
                            'doctorName': doctorName,

                            'specialty': _doctorData!['specialty'] ?? 'N/A',
                       }
                    );
                },
                style: ElevatedButton.styleFrom(
                   backgroundColor: AppPallete.primaryColor,
                   foregroundColor: Colors.white,
                   minimumSize: const Size(double.infinity, 50),
                   shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                   ),
                   elevation: 3,
                ),
                child: const Text(
                   'Book Appointment',
                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
          ),
      );
   }
}
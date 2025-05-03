import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor/doctor_dahboard/pat_list_db.dart'; // Keep this DB

// Removed the DashboardScreen StatefulWidget wrapper and its hardcoded patientId
// The PatientList widget should be directly used in the router now.

class PatientList extends StatefulWidget {
  const PatientList({Key? key}) : super(key: key); // Added Key

  @override
  _PatientListPageState createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientList> {
  final PatListDB _db = PatListDB();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  List<Map<String, dynamic>> removedPatients = []; // Keep track of removed
  bool _isLoading = true;
  String? _errorMessage; // For error handling
  // Removed _selectedIndex as BottomNavBar is handled by MainLayout

  // Example PDF list - This should ideally come from patient data
  final List<List<String>> patientFilesList = [
    ['Prescription.pdf', 'X-ray report.pdf'], ['Checkup.pdf'], ['Prescription.pdf'],
    ['X-ray report.pdf', 'Prescription.pdf'], ['Checkup.pdf'], ['Prescription.pdf', 'X-ray report.pdf'],
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() { // Dispose controller
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
     if (!mounted) return;
    setState(() {
       _isLoading = true;
       _errorMessage = null; // Clear previous errors
    });

    try {
      final patientsData = await _db.getAllPatientsBasicInfo();
      if (!mounted) return;
      setState(() {
        patients = patientsData;
        // Apply filter immediately if search query exists
        _filterPatients();
        _isLoading = false;
      });
    } catch (e) {
       if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load patients: ${e.toString().replaceFirst('Exception: ','')}';
        patients = []; // Clear data on error
        filteredPatients = [];
      });
      // Optionally show a Snackbar
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(_errorMessage!)),
      // );
    }
  }

  void _filterPatients() {
     if (!mounted) return;
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredPatients = List.from(patients); // Reset to full list
      } else {
        filteredPatients = patients.where((patient) {
          final firstName = patient['first_name']?.toString().toLowerCase() ?? '';
          final lastName = patient['last_name']?.toString().toLowerCase() ?? '';
          final fullName = '$firstName $lastName';
          // Optionally search by Age or Gender if needed
          // final age = patient['Age']?.toString() ?? '';
          // final gender = patient['gender']?.toString().toLowerCase() ?? '';
          return fullName.contains(query);
        }).toList();
      }
    });
  }

  // Note: Removing patients might be better handled by updating a status
  // in the database rather than just removing from the local list permanently.
  void _removePatient(int indexInFilteredList) {
     if (!mounted) return;
    final patientToRemove = filteredPatients[indexInFilteredList];
    final originalIndex = patients.indexWhere((p) => p['patient_id'] == patientToRemove['patient_id']); // Assuming 'patient_id' exists

    setState(() {
      removedPatients.add(patientToRemove);
      if (originalIndex != -1) {
         patients.removeAt(originalIndex);
      }
      filteredPatients.removeAt(indexInFilteredList);
    });
    // Optionally show Snackbar with Undo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${patientToRemove['first_name']} removed"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () => _restoreLastRemoved(),
        ),
      ),
    );
  }

  void _restoreLastRemoved() {
     if (!mounted || removedPatients.isEmpty) return;
    setState(() {
      final patientToRestore = removedPatients.removeLast();
      patients.add(patientToRestore); // Add back to original list
      _filterPatients(); // Re-apply filter
    });
  }

  void _restoreAllRemoved() {
     if (!mounted || removedPatients.isEmpty) return;
    setState(() {
      patients.addAll(removedPatients);
      removedPatients.clear();
      _filterPatients(); // Re-apply filter
    });
  }


  void _showPatientFiles(int patientIndexInFiltered) {
    // Ensure index is valid for the filtered list
     if (patientIndexInFiltered < 0 || patientIndexInFiltered >= filteredPatients.length) return;

     // TODO: Fetch actual files associated with the patient ID instead of using index
     // final patientId = filteredPatients[patientIndexInFiltered]['patient_id'];
     // final files = await fetchFilesForPatient(patientId); // Implement this function
     // For now, using the placeholder list based on index:
    final files = patientIndexInFiltered < patientFilesList.length
        ? patientFilesList[patientIndexInFiltered]
        : ['No files available'];

    final patientName = '${filteredPatients[patientIndexInFiltered]['first_name'] ?? ''} '
        '${filteredPatients[patientIndexInFiltered]['last_name'] ?? ''}'.trim();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$patientName\'s Files', style: TextStyle(color: Colors.black)), // Use standard text color
          content: SizedBox( // Constrain height if list can be long
            width: double.maxFinite,
            child: ListView.builder(
               shrinkWrap: true,
               itemCount: files.length,
               itemBuilder: (context, index) {
                 final file = files[index];
                 return ListTile(
                   dense: true, // Make list items compact
                   leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                   title: Text(file, style: TextStyle(fontSize: 14)), // Smaller font
                   trailing: IconButton(
                     icon: const Icon(Icons.download, color: AppPallete.primaryColor),
                     onPressed: () => _downloadFile(file),
                   ),
                 );
               },
             ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: AppPallete.primaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _downloadFile(String fileName) {
     // TODO: Implement actual file download logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $fileName...'),
        backgroundColor: AppPallete.primaryColor,
      ),
    );
  }

  // Removed _onItemTapped as BottomNavBar is handled by MainLayout

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor, // Use consistent background
      appBar: AppBar(
        backgroundColor: AppPallete.whiteColor, // White AppBar
        elevation: 1, // Subtle elevation
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppPallete.primaryColor),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/d_dashboard'); // Fallback to doctor dashboard
            }
          },
        ),
        title: const Text( // Use const
          'Patient List & Reports',
          style: TextStyle(
            color: AppPallete.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20, // Adjusted size
          ),
        ),
        centerTitle: true, // Center title
        actions: [
          if (removedPatients.isNotEmpty) // Show restore button only if needed
            IconButton(
              tooltip: 'Restore Removed Patients', // Add tooltip
              icon: const Icon(Icons.restore_from_trash, color: AppPallete.primaryColor),
              onPressed: _restoreAllRemoved,
            ),
        ],
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
                prefixIcon: const Icon(Icons.search, color: AppPallete.greyColor),
                filled: true,
                fillColor: AppPallete.whiteColor, // White background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppPallete.borderColor), // Subtle border
                ),
                 enabledBorder: OutlineInputBorder( // Consistent border
                   borderRadius: BorderRadius.circular(10),
                   borderSide: const BorderSide(color: AppPallete.borderColor),
                 ),
                 focusedBorder: OutlineInputBorder( // Highlight border on focus
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppPallete.primaryColor, width: 1.5),
                  ),
                 contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Adjust padding
              ),
            ),
            const SizedBox(height: 16),
            // Patient List Area
            Expanded(
              // Removed flex: 2, let it expand naturally
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                     ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
                     : filteredPatients.isEmpty
                        ? Center(child: Text(_searchController.text.isEmpty ? 'No patients found.' : 'No results for "${_searchController.text}"'))
                        : RefreshIndicator( // Add pull-to-refresh
                            onRefresh: _loadPatients,
                            child: ListView.builder(
                             itemCount: filteredPatients.length,
                             itemBuilder: (context, index) {
                               final patient = filteredPatients[index];
                               final patientName = '${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}'.trim();
                               return Card( // Use Card for better structure
                                 margin: const EdgeInsets.only(bottom: 10),
                                 elevation: 2,
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                 child: ListTile(
                                   onTap: () => _showPatientFiles(index), // Tap to view files
                                   leading: CircleAvatar( // Standard avatar
                                     backgroundColor: AppPallete.primaryColor.withOpacity(0.1),
                                     child: Text(
                                       '${patient['first_name']?[0] ?? ''}${patient['last_name']?[0] ?? ''}'.toUpperCase(), // Use initials
                                       style: const TextStyle(fontWeight: FontWeight.bold, color: AppPallete.primaryColor),
                                     ),
                                   ),
                                   title: Text(
                                     patientName,
                                     style: const TextStyle(
                                         color: AppPallete.textColor,
                                         fontWeight: FontWeight.w500),
                                   ),
                                   subtitle: Text(
                                     "${patient['gender']}, Age: ${patient['Age']}", // Combine info
                                     style: const TextStyle(color: AppPallete.greyColor),
                                   ),
                                   trailing: PopupMenuButton<String>(
                                     icon: const Icon(Icons.more_vert, color: AppPallete.greyColor), // Standard more icon
                                     onSelected: (value) {
                                       if (value == 'Remove') {
                                         _removePatient(index);
                                       } else if (value == 'View Files') {
                                         _showPatientFiles(index);
                                       }
                                       // Add other actions if needed
                                     },
                                     itemBuilder: (context) => [
                                       const PopupMenuItem(
                                         value: 'View Files',
                                         child: Text('View Files', style: TextStyle(color: AppPallete.textColor)),
                                       ),
                                       const PopupMenuItem(
                                         value: 'Remove',
                                         child: Text('Remove', style: TextStyle(color: Colors.red)), // Red for remove
                                       ),
                                     ],
                                   ),
                                 ),
                               );
                             },
                                                   ),
                         ),
            ),
          ],
        ),
      ),
      // Removed local BottomNavBar, relies on MainLayout
    );
  }
}
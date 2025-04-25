import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor/doctor_dahboard/pat_list_db.dart';

class PatientList extends StatelessWidget {
  const PatientList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String patientId = "adcb6404-d3f4-4f0d-bb53-467f0ef2fd5c";
    return DashboardScreen(patientId: patientId);
  }
}

class DashboardScreen extends StatefulWidget {
  final String patientId;
  const DashboardScreen({required this.patientId, Key? key}) : super(key: key);

  @override
  _PatientListPageState createState() => _PatientListPageState();
}

class _PatientListPageState extends State<DashboardScreen> {
  final PatListDB _db = PatListDB();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  List<Map<String, dynamic>> removedPatients = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  // List of PDF file sets (in order)
  final List<List<String>> patientFilesList = [
    ['Prescription.pdf', 'X-ray report.pdf'],
    ['Checkup.pdf'],
    ['Prescription.pdf'],
    ['X-ray report.pdf', 'Prescription.pdf'],
    ['Checkup.pdf'],
    ['Prescription.pdf', 'X-ray report.pdf'],
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_filterPatients);
  }

  Future<void> _loadPatients() async {
    try {
      final patientsData = await _db.getAllPatientsBasicInfo();
      setState(() {
        patients = patientsData;
        filteredPatients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load patients: ${e.toString()}')),
      );
    }
  }

  void _filterPatients() {
    setState(() {
      filteredPatients = patients.where((patient) {
        final firstName = patient['first_name']?.toString().toLowerCase() ?? '';
        final lastName = patient['last_name']?.toString().toLowerCase() ?? '';
        final fullName = '$firstName $lastName';
        return fullName.contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  void _removePatient(int index) {
    setState(() {
      final patientToRemove = filteredPatients[index];
      removedPatients.add(patientToRemove);
      patients.removeWhere((p) =>
      p['first_name'] == patientToRemove['first_name'] &&
          p['last_name'] == patientToRemove['last_name']);
      filteredPatients.removeAt(index);
    });
  }

  void _restorePatients() {
    setState(() {
      patients.addAll(removedPatients);
      filteredPatients = List.from(patients);
      removedPatients.clear();
    });
  }

  void _showPatientFiles(int patientIndex) {
    // Get files based on position in list (with safety check)
    final files = patientIndex < patientFilesList.length
        ? patientFilesList[patientIndex]
        : ['No files available'];

    final patientName = '${filteredPatients[patientIndex]['first_name'] ?? ''} '
        '${filteredPatients[patientIndex]['last_name'] ?? ''}'.trim();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$patientName Files',
              style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (String file in files)
                ListTile(
                  leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: Text(file),
                  trailing: IconButton(
                    icon: Icon(Icons.download, color: AppPallete.primaryColor),
                    onPressed: () => _downloadFile(file),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: AppPallete.primaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _downloadFile(String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $fileName...'),
        backgroundColor: AppPallete.primaryColor,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppPallete.secondaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppPallete.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Text(
            'Patient List & Reports',
            style: TextStyle(
              color: AppPallete.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.restore, color: AppPallete.primaryColor),
            onPressed: _restorePatients,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                hintStyle: TextStyle(color: AppPallete.textColor),
                prefixIcon: Icon(Icons.search, color: AppPallete.textColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppPallete.darkText),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 2,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: filteredPatients.length,
                itemBuilder: (context, index) {
                  final patient = filteredPatients[index];
                  final patientName = '${patient['first_name'] ?? ''} '
                      '${patient['last_name'] ?? ''}'.trim();
                  return ListTile(
                    onTap: () => _showPatientFiles(index),
                    leading: CircleAvatar(
                      child: Text(
                        '${patient['first_name']?[0] ?? ''}'
                            '${patient['last_name']?[0] ?? ''}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      patientName,
                      style: TextStyle(
                          color: AppPallete.textColor,
                          fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      "${patient['gender']}, ${patient['Age']}",
                      style: TextStyle(color: AppPallete.greyColor),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'Remove') {
                          _removePatient(index);
                        } else if (value == 'View Files') {
                          _showPatientFiles(index);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'View Files',
                          child: Text('View Files',
                              style: TextStyle(color: AppPallete.textColor)),
                        ),
                        PopupMenuItem(
                          value: 'Remove',
                          child: Text('Remove',
                              style: TextStyle(color: AppPallete.textColor)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppPallete.primaryColor,
        unselectedItemColor: AppPallete.greyColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ""),
        ],
      ),
    );
  }
}
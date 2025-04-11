import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/patient_dashboard/menu_nav.dart';
import 'package:medical_app/features/patient_dashboard/pages/favorite.dart';
import 'package:medical_app/features/patient_dashboard/dashboard_db.dart';
import 'package:medical_app/features/patient_dashboard/pages/doctor_search.dart';

void main() {
  runApp(const Dashboard());
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardDB _dashboardDB = DashboardDB();
  final String patientId = "a5073dd2-a726-43e6-9a25-1454ac6dfda5";
  String patientFirstName = '';
  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? upcomingAppointment;
  List<Map<String, dynamic>> availableDoctors = [];
  bool doctorsLoading = true;
  bool appointmentLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {

      setState(() {
        isLoading = true;
        appointmentLoading = true;
        doctorsLoading = true;
      });
      final name = await _dashboardDB.getPatientFirstName(patientId);
      final appointment = await _dashboardDB.getUpcomingAppointment(patientId);

      final doctorIds = [
        "79ee85c5-c5da-41f5-b4a0-579f4792f32f",
        "82068a58-ffa9-4ab9-ab9e-c27b490c7e49",
        "9968ff7d-9319-4fba-8104-7b5a6bc6f3db"
      ];

      final doctors = await _dashboardDB.getMultipleDoctors(doctorIds);

      setState(() {
        patientFirstName = name;
        upcomingAppointment = appointment;
        availableDoctors = doctors;
        isLoading = false;
        doctorsLoading = false;
        appointmentLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        doctorsLoading = false;
        errorMessage = e.toString();
        appointmentLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      drawer: const Drawer(child: SideMenu()),
      backgroundColor: AppPallete.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderSection(),
              _buildSearchSection(),
              _buildQuickAccessSection(),
              _buildUpcomingAppointmentSection(),
              _buildAvailableDoctorsSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppPallete.textColor),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundImage: AssetImage('assets/images/patient.jpeg'),
              ),
              const SizedBox(width: 7),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hi, Welcome Back',
                    style: TextStyle(
                      fontSize: 17,
                      color: AppPallete.headings,
                    ),
                  ),
                  Text(
                    patientFirstName,
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppPallete.textColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppPallete.textColor,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Column(
            children: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Favorite(patientId: patientId),
                  ),
                ),
                icon: const Icon(
                  Icons.favorite_border_outlined,
                  color: AppPallete.primaryColor,
                  size: 30,
                ),
              ),
              const Text(
                'Favorite',
                style: TextStyle(
                  fontSize: 14,
                  color: AppPallete.headings,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onTap: () async {
                final selectedDoctor = await showSearch<Map<String, dynamic>?>(
                  context: context,
                  delegate: DoctorSearchDelegate(dashboardDB: _dashboardDB),
                );
                if (selectedDoctor != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected: ${selectedDoctor['firstName']}'),
                    ),
                  );
                }
              },
              decoration: InputDecoration(
                hintText: 'Search doctors...',
                prefixIcon: const Icon(Icons.search_outlined),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _QuickAccessButton(
            icon: Icons.medical_services_outlined,
            label: 'Doctor',
          ),
          _QuickAccessButton(
            icon: Icons.local_pharmacy_rounded,
            label: 'Pharmacy',
          ),
          _QuickAccessButton(
            icon: Icons.local_hospital_rounded,
            label: 'Hospital',
          ),
          _QuickAccessButton(
            icon: Icons.local_hospital_outlined,
            label: 'Ambulance',
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Row(
            children: [
              Text(
                'Upcoming Schedule',
                style: TextStyle(
                  fontSize: 24,
                  color: AppPallete.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildAppointmentCard(),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard() {
    if (appointmentLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (upcomingAppointment == null) {
      return Container(
        child: const Text(
          'No upcoming appointments',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final doctor = upcomingAppointment!['doctor'];
    final appointmentDate = DateTime.parse(upcomingAppointment!['appointment_date']);
    final formattedDate = DateFormat('EEEE, MMMM d').format(appointmentDate);
    final appointmentTime = upcomingAppointment!['appointment_time'] as String;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppPallete.headings,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppPallete.greyColor,
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundImage: AssetImage('assets/images/doctor.jpg'),
                ),
                const SizedBox(width: 7),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${doctor['title']} ${doctor['first_name']} ${doctor['last_name']}',
                      style: const TextStyle(
                        fontSize: 21,
                        color: AppPallete.whiteColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      doctor['specialty'],
                      style: const TextStyle(
                        fontSize: 19,
                        color: AppPallete.whiteColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$formattedDate • $appointmentTime',
                      style: const TextStyle(
                        fontSize: 17,
                        color: AppPallete.whiteColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 100),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 123,
                    decoration: BoxDecoration(
                      color: AppPallete.whiteColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.video_call_rounded,
                            color: AppPallete.primaryColor,
                          ),
                          onPressed: null,
                        ),
                        Text(
                          'Join Call',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableDoctorsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Row(
            children: [
              Text(
                'On Demand',
                style: TextStyle(
                  fontSize: 24,
                  color: AppPallete.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDoctorsList(),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    if (doctorsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (availableDoctors.isEmpty) {
      return const Text('No doctors available');
    }

    return Column(
      children: availableDoctors.map((doctor) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: _DoctorCard(
          doctor: doctor,
          patientId: patientId,
          dashboardDB: _dashboardDB,
          onFavoriteChanged: () => setState(() {}),
        ),
      )).toList(),
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickAccessButton({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.grey.shade200,
            elevation: 3,
          ),
          child: Icon(
            icon,
            color: AppPallete.headings,
            size: 30,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppPallete.headings,
          ),
        ),
      ],
    );
  }
}

class _DoctorCard extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final String patientId;
  final DashboardDB dashboardDB;
  final VoidCallback onFavoriteChanged;

  const _DoctorCard({
    required this.doctor,
    required this.patientId,
    required this.dashboardDB,
    required this.onFavoriteChanged,
  });

  @override
  State<_DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<_DoctorCard> {
  bool isFavorite = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final status = await widget.dashboardDB.isDoctorFavorited(
        widget.patientId,
        widget.doctor['id'],
      );
      setState(() {
        isFavorite = status;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking favorite status: $e')),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      setState(() {
        isLoading = true;
      });

      if (isFavorite) {
        await widget.dashboardDB.removeFavorite(
          widget.patientId,
          widget.doctor['id'],
        );
      } else {
        await widget.dashboardDB.addFavorite(
          widget.patientId,
          widget.doctor['id'],
        );
      }

      setState(() {
        isFavorite = !isFavorite;
        isLoading = false;
      });
      widget.onFavoriteChanged();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating favorite: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppPallete.secondaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: AppPallete.greyColor,
            blurRadius: 1,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage('assets/images/doctor.jpg'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.doctor['title']} ${widget.doctor['firstName']} ${widget.doctor['lastName']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.primaryColor,
                  ),
                ),
                Text(
                  widget.doctor['specialty'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppPallete.greyColor,
                  ),
                ),
              ],
            ),
          ),
          isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.blue : AppPallete.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
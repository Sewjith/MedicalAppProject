import 'package:flutter/material.dart';
import 'package:medical_app/features/appoinment_history/upcoming.dart';
import 'package:medical_app/features/appoinment_history/cancelled.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medical_app/features/appoinment_history/review.dart';
void main() {
  runApp(const Appointment());
}

class Appointment extends StatelessWidget {
  const Appointment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Appointment History',
      theme: ThemeData(
        primaryColor: AppPallete.primaryColor,
        fontFamily: 'Arial',
        primarySwatch: Colors.blue,
      ),
      home: const CompletedAppointmentsPage(),
    );
  }
}

class AppointmentDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getCompletedAppointments() async {
    try {
      final appointments = await _supabase
          .from('appointments')
          .select('id, doctor_name, doctor_id, appointment_date, appointment_status')
          .eq('appointment_status', 'complete')
          .order('appointment_date', ascending: false);

      if (appointments.isEmpty) return [];

      return await _processAppointments(appointments);
    } catch (e) {
      debugPrint('Error loading appointments: $e');
      throw Exception('Failed to load appointments. Please try again later.');
    }
  }

  Future<List<Map<String, dynamic>>> _processAppointments(List<dynamic> appointments) async {
    final validAppointments = appointments.where((a) => a['doctor_id'] != null).toList();
    final noDoctorAppointments = appointments.where((a) => a['doctor_id'] == null).toList();

    final doctorIds = validAppointments.map((a) => a['doctor_id'] as String).toList();
    List<Map<String, dynamic>> doctors = [];

    if (doctorIds.isNotEmpty) {
      doctors = await _supabase
          .from('doctors')
          .select('id, specialty, avatar_path')
          .inFilter('id', doctorIds);
    }

    final processedAppointments = <Map<String, dynamic>>[];

    for (final appointment in validAppointments) {
      final doctor = doctors.firstWhere(
            (d) => d['id'] == appointment['doctor_id'],
        orElse: () => {
          'specialty': 'Unknown Specialty',
          'avatar_path': null,
        },
      );
      processedAppointments.add(_createAppointmentMap(appointment, doctor));
    }

    for (final appointment in noDoctorAppointments) {
      processedAppointments.add(_createAppointmentMap(appointment, {
        'specialty': 'No Specialty',
        'avatar_path': null,
      }));
    }

    return processedAppointments;
  }

  Map<String, dynamic> _createAppointmentMap(
      dynamic appointment,
      Map<String, dynamic> doctor
      ) {
    final avatarPath = doctor['avatar_path'];
    final imageUrl = avatarPath != null
        ? '${_supabase.storage.from('avatars').getPublicUrl(avatarPath)}'
        : 'assets/images/default_doctor.png';

    return {
      ...appointment,
      'specialty': doctor['specialty'],
      'image_url': imageUrl,
    };
  }
}

class CompletedAppointmentsPage extends StatefulWidget {
  const CompletedAppointmentsPage({Key? key}) : super(key: key);

  @override
  _CompletedAppointmentsPageState createState() => _CompletedAppointmentsPageState();
}

class _CompletedAppointmentsPageState extends State<CompletedAppointmentsPage> {
  final AppointmentDB _db = AppointmentDB();
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final appointments = await _db.getCompletedAppointments();
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading appointments: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Appointment',
          style: TextStyle(
            color: AppPallete.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppPallete.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined,
              color: AppPallete.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    backgroundColor: AppPallete.primaryColor,
                    foregroundColor: AppPallete.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Complete',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Upcoming()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.lightBackground,
                    foregroundColor: AppPallete.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Upcoming',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Cancel()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.lightBackground,
                    foregroundColor: AppPallete.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Cancelled',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _appointments.isEmpty
                ? const Center(
              child: Text(
                'No completed appointments found',
                style: TextStyle(color: AppPallete.textColor),
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadAppointments,
              child: ListView(
                children: _appointments.map((appointment) => AppointmentCard(
                  doctorName: appointment['doctor_name'] ?? 'Unknown Doctor',
                  specialty: appointment['specialty'] ?? 'Unknown Specialty',
                  imageUrl: appointment['image_url'],
                  onReviewPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Review(
                          doctorId: appointment['doctor_id'],
                          doctorName: appointment['doctor_name'],
                          specialty: appointment['specialty'],
                          imageUrl: appointment['image_url'],
                        ),
                      ),
                    );
                  },
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String imageUrl;
  final VoidCallback onReviewPressed;

  const AppointmentCard({
    Key? key,
    required this.doctorName,
    required this.specialty,
    required this.imageUrl,
    required this.onReviewPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: imageUrl.startsWith('http')
                      ? NetworkImage(imageUrl)
                      : AssetImage(imageUrl) as ImageProvider,
                  radius: 30,
                  onBackgroundImageError: (_, __) =>
                  const Icon(Icons.person, size: 30),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppPallete.primaryColor,
                        ),
                      ),
                      Text(
                        specialty,
                        style: const TextStyle(color: AppPallete.textColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

          ],
        ),
      ),
    );
  }
}
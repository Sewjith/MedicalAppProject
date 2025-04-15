import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/medication_reminder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(Vaccination_Reminder());
}

class Vaccination_Reminder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VaccinationPage(),
    );
  }
}

class VaccinationPage extends StatefulWidget {
  @override
  _VaccinationPageState createState() => _VaccinationPageState();
}

class _VaccinationPageState extends State<VaccinationPage> {
  final VaccinationDB _vaccinationDB = VaccinationDB();
  List<Map<String, dynamic>> vaccinePlan = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVaccinations();
  }

  Future<void> _loadVaccinations() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final vaccinations = await _vaccinationDB.getPatientVaccinations();
      setState(() {
        vaccinePlan = vaccinations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppPallete.transparentColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_sharp, color: AppPallete.headings),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Medication_Reminder()),
            );
          },
        ),
        title: Text(
          "Today's Plan",
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: AppPallete.headings,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, d MMM y').format(DateTime.now()),
                style: TextStyle(
                  color: AppPallete.textColor,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else if (errorMessage != null)
                Center(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: AppPallete.errorColor),
                  ),
                )
              else if (vaccinePlan.isEmpty)
                  Center(child: Text('No vaccinations scheduled for today'))
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: vaccinePlan.length,
                      itemBuilder: (context, index) {
                        final item = vaccinePlan[index];
                        return VaccineCard(
                          name: item['medicine_name'] ?? '',
                          details: item['description'] ?? '',
                          frequency: item['frequency'] ?? '',

                        );
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class VaccineCard extends StatelessWidget {
  final String name;
  final String details;
  final String frequency;


  const VaccineCard({
    required this.name,
    required this.details,
    required this.frequency,

  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.vaccines_outlined, color: AppPallete.headings, size: 40),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (details.isNotEmpty)
                    Text(details, style: TextStyle(fontSize: 14, color: Colors.black45)),
                  if (frequency.isNotEmpty)
                    Text('Frequency: $frequency', style: TextStyle(fontSize: 14, color: Colors.black45)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class VaccinationDB {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String prescriptionId = "11c889b9-771e-4e30-aaa0-79cda9b15f38";

  Future<List<Map<String, dynamic>>> getPatientVaccinations() async {
    try {
      final today = DateTime.now();
      final todayStr = today.toIso8601String();

      final response = await _supabase
          .from('prescription_medicines')
          .select('''
            id,
            frequency,
            notes,
            time_of_day,
            start_date,
            prescription:prescriptions!fk_prescription(
              id,
              prescription_id,
              date_issued,
              patient_id
            ),
            medicine:medicines!inner(name, description, type)
          ''')
          .eq('prescription_id', prescriptionId)
          .eq('medicine.type', 'Vaccine')
          .lte('start_date', todayStr)
          .order('time_of_day', ascending: true);

      if (response.isEmpty) return [];

      return _processMedicationData(response, today);
    } catch (e) {
      throw Exception('Failed to load vaccinations: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  List<Map<String, dynamic>> _processMedicationData(List<dynamic> medications, DateTime today) {
    List<Map<String, dynamic>> result = [];

    for (final med in medications) {
      final startDate = DateTime.parse(med['start_date']);
      final endDate = startDate.add(Duration(days: 1));

      final remainingDays = endDate.difference(today).inDays + 1;

      if (today.isBefore(endDate.add(Duration(days: 1)))) {
        result.add({
          'id': med['id'],
          'prescription_id': med['prescription']?['prescription_id'],
          'medicine_name': med['medicine']?['name'] ?? 'Unknown Vaccine',
          'frequency': med['frequency'] ?? '',
          'remaining_days': remainingDays > 0 ? remainingDays : 0,
          'time': _formatTimeOfDay(med['time_of_day']),
          'instructions': med['notes'] ?? '',
          'description': med['medicine']?['description'] ?? '',
          'start_date': med['start_date'],
          'end_date': endDate.toIso8601String(),
        });
      }
    }

    result.sort((a, b) {
      if (a['time'] == 'Anytime') return 1;
      if (b['time'] == 'Anytime') return -1;
      return a['time'].compareTo(b['time']);
    });

    return result;
  }

  String _formatTimeOfDay(String? time) {
    if (time == null) return 'Anytime';
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return 'Anytime';
  }
}

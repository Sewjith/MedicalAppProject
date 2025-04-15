import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/Vaccination_Reminder.dart';
import 'package:medical_app/features/pillDetails.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(Medication_Reminder());
}

class Medication_Reminder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ReminderPage(),
    );
  }
}

class ReminderPage extends StatefulWidget {
  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final MedicationDB _medicationDB = MedicationDB();
  List<Map<String, dynamic>> pillPlan = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final medications = await _medicationDB.getPatientMedications();
      setState(() {
        pillPlan = medications;
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Today's Plan",
          style: TextStyle(
            color: AppPallete.headings,
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.vaccines_outlined, color: AppPallete.headings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Vaccination_Reminder()),
            ),
          ),
        ],
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
              else if (pillPlan.isEmpty)
                  Center(child: Text('No medications scheduled for today'))
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: pillPlan.length,
                      itemBuilder: (context, index) {
                        final remainingDays = pillPlan[index]['remaining_days'];
                        final daysText = remainingDays > 0
                            ? '$remainingDays ${remainingDays == 1 ? 'day' : 'days'} left'
                            : 'Last day';

                        return PillCard(
                          time: pillPlan[index]['time'] ?? '',
                          name: pillPlan[index]['medicine_name'] ?? '',
                          frequency: pillPlan[index]['frequency'] ?? '',
                          daysLeft: daysText,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PillDetails(
                                  id: pillPlan[index]['id'],
                                  name: pillPlan[index]['medicine_name'],
                                  details: pillPlan[index]['description'] ?? '',
                                  duration: pillPlan[index]['duration'],
                                  takenDays: pillPlan[index]['taken_days'] ?? 0,
                                ),
                              ),
                            );
                          },
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

class PillCard extends StatelessWidget {
  final String time;
  final String name;
  final String frequency;
  final String daysLeft;
  final VoidCallback onTap;

  const PillCard({
    required this.time,
    required this.name,
    required this.frequency,
    required this.daysLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppPallete.textColor,
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.medication_rounded, color: AppPallete.headings, size: 40),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          frequency,
                          style: TextStyle(fontSize: 14, color: Colors.black45),
                        ),
                        SizedBox(height: 4),
                        Text(
                          daysLeft,
                          style: TextStyle(fontSize: 14, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios_outlined, color: Colors.black45),
                    onPressed: onTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MedicationDB {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String prescriptionId = "11c889b9-771e-4e30-aaa0-79cda9b15f38";

  Future<List<Map<String, dynamic>>> getPatientMedications() async {
    try {
      final today = DateTime.now();
      final todayStr = today.toIso8601String();

      final response = await _supabase
          .from('prescription_medicines')
          .select('''
            id,
            frequency,
            duration,
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
          .eq('medicine.type', 'Pill')
          .lte('start_date', todayStr)
          .order('time_of_day', ascending: true);

      if (response.isEmpty) return [];

      return _processMedicationData(response, today);
    } catch (e) {
      throw Exception('Failed to load medications: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  List<Map<String, dynamic>> _processMedicationData(List<dynamic> medications, DateTime today) {
    List<Map<String, dynamic>> result = [];

    for (final med in medications) {
      final startDate = DateTime.parse(med['start_date']);
      final duration = (med['duration'] as num).toInt();
      final endDate = startDate.add(Duration(days: duration));
      final remainingDays = endDate.difference(today).inDays + 1;

      if (today.isBefore(endDate.add(Duration(days: 1)))) {
        result.add({
          'id': med['id'],
          'prescription_id': med['prescription']?['prescription_id'],
          'medicine_name': med['medicine']?['name'] ?? 'Unknown Medicine',
          'frequency': med['frequency'] ?? '',
          'duration': duration,
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
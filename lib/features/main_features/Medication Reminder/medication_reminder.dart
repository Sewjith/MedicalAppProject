import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/main_features/Medication%20reminder/Vaccination_Reminder.dart';
import 'package:medical_app/features/main_features/Medication%20reminder/pillDetails.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  TimeOfDay? _timeOfDay;
  final TextEditingController _notesController = TextEditingController();

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

  Future<void> _addMedicationReminder() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isLoading = true; 
        });

        await _medicationDB.addMedicationReminder(
          medicineName: _medicineNameController.text.trim(),
          dosage: _dosageController.text.trim(),
          frequency: _frequencyController.text.trim(),
          startDate: DateTime.now(),
          durationDays: int.parse(_durationController.text.trim()),
          timeOfDay: _timeOfDay,
          notes: _notesController.text.trim(),
        );

        _medicineNameController.clear();
        _dosageController.clear();
        _frequencyController.clear();
        _durationController.clear();
        _timeController.clear();
        _timeOfDay = null;
        _notesController.clear();

        await _loadMedications();

        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Medication reminder added successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the success dialog
                    Navigator.of(context)
                        .pop(); // Close the add reminder dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding reminder: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteReminder(String id, bool isPrescription) async {
    try {
      await _medicationDB.deleteReminder(id, isPrescription);
      _loadMedications(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting reminder: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(String id, bool isPrescription) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Reminder'),
          content: Text('Are you sure you want to delete this reminder?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteReminder(id, isPrescription);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _timeOfDay = pickedTime;
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Medication Reminder'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _medicineNameController,
                    decoration:
                        const InputDecoration(labelText: 'Medicine Name*'),
                    validator: (value) =>
                        value!.isEmpty ? 'Medicine name is required' : null,
                  ),
                  TextFormField(
                    controller: _dosageController,
                    decoration: const InputDecoration(labelText: 'Dosage*'),
                    validator: (value) =>
                        value!.isEmpty ? 'Dosage is required' : null,
                  ),
                  TextFormField(
                    controller: _frequencyController,
                    decoration: const InputDecoration(labelText: 'Frequency*'),
                    validator: (value) =>
                        value!.isEmpty ? 'Frequency is required' : null,
                  ),
                  TextFormField(
                    controller: _durationController,
                    decoration:
                        const InputDecoration(labelText: 'Duration (Days)*'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Duration is required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid duration';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _timeController,
                    decoration: InputDecoration(
                      labelText: 'Time*',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.access_time),
                        onPressed: () => _selectTime(context),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectTime(context),
                    validator: (value) =>
                        value!.isEmpty ? 'Please select a time' : null,
                  ),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addMedicationReminder,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppPallete.transparentColor,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_sharp, color: AppPallete.headings),
          onPressed: () {
            if (context.canPop()) { 
               context.pop(); 
            } else {
                context.go('/p_dashboard');
            }
          }
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

                      return Dismissible(
                        key: Key(pillPlan[index]['id']),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _showDeleteConfirmationDialog(
                            pillPlan[index]['id'],
                            pillPlan[index]['is_prescription'] ?? false,
                          );
                        },
                        child: PillCard(
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
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        tooltip: 'Add Medication Reminder',
        child: const Icon(Icons.add),
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
                  Icon(Icons.medication_rounded,
                      color: AppPallete.headings, size: 40),
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
                    icon: Icon(Icons.arrow_forward_ios_outlined,
                        color: Colors.black45),
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

      // Fetch prescription medicines
      final prescriptionResponse = await _supabase
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

      List<dynamic> allMedications = [];
      if (prescriptionResponse != null) {
        allMedications.addAll(prescriptionResponse);
      }

      // Fetch user-added reminders
      final reminderResponse = await _supabase
          .from('medication_reminders')
          .select('''
            id,
            medicine_name,
            dosage,
            frequency,
            start_date,
            duration_days,
            time_of_day,
            notes
          ''')
          .eq('patient_id', _supabase.auth.currentUser!.id)
          .lte('start_date', todayStr)
          .order('time_of_day', ascending: true);

      if (reminderResponse != null) {
        allMedications.addAll(reminderResponse);
      }

      if (allMedications.isEmpty) return [];

      return _processMedicationData(allMedications, today);
    } catch (e) {
      throw Exception(
          'Failed to load medications: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  List<Map<String, dynamic>> _processMedicationData(
      List<dynamic> medications, DateTime today) {
    List<Map<String, dynamic>> result = [];

    for (final med in medications) {
      DateTime startDate;
      int duration = 0;
      String? time;
      String medicineName;
      String frequency;
      String description = ''; // Provide a default value
      String notes = '';
      bool isPrescription = false;

      try {
        if (med.containsKey('prescription_id')) {
          // Data from prescription_medicines
          isPrescription = true;
          startDate = DateTime.parse(med['start_date']);
          duration = (med['duration'] as num).toInt(); 
          time = med['time_of_day'];
          medicineName = med['medicine']?['name'] ?? 'Unknown Medicine';
          frequency = med['frequency'] ?? '';
          description = med['medicine']?['description'] ?? '';
          notes = med['notes'] ?? '';
        } else {
          // Data from medication_reminders
          isPrescription = false;
          startDate = DateTime.parse(med['start_date']);
          duration = med['duration_days'] as int; 
          time = med['time_of_day'];
          medicineName = med['medicine_name'];
          frequency = med['frequency'];
          notes = med['notes'] ?? '';
        }

        final endDate = startDate.add(Duration(days: duration));
        final remainingDays = endDate.difference(today).inDays + 1;

        if (today.isBefore(endDate.add(Duration(days: 1)))) {
          result.add({
            'id': med['id'],
            'medicine_name': medicineName,
            'frequency': frequency,
            'duration': duration,
            'remaining_days': remainingDays > 0 ? remainingDays : 0,
            'time': _formatTimeOfDay(time),
            'notes': notes,
            'description': description,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate.toIso8601String(),
            'is_prescription': isPrescription,
          });
        }
      } catch (e) {
        print('Error processing medication: $med - $e');

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

  Future<void> addMedicationReminder({
    required String medicineName,
    required String dosage,
    required String frequency,
    required DateTime startDate,
    required int durationDays,
    TimeOfDay? timeOfDay,
    required String notes,
  }) async {
    try {
      await _supabase.from('medication_reminders').insert({
        'patient_id':
            _supabase.auth.currentUser!.id, // Assuming user is logged in
        'medicine_name': medicineName,
        'dosage': dosage,
        'frequency': frequency,
        'start_date': startDate.toIso8601String(),
        'duration_days': durationDays,
        'time_of_day': timeOfDay != null
            ? '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}:00'
            : null,
        'notes': notes,
      });
    } catch (e) {
      throw Exception('Failed to add medication reminder: ${e.toString()}');
    }
  }

  Future<void> deleteReminder(String id, bool isPrescription) async {
    try {
      if (isPrescription) {
        await _supabase.from('prescription_medicines').delete().eq('id', id);
      } else {
        await _supabase.from('medication_reminders').delete().eq('id', id);
      }
    } catch (e) {
      throw Exception('Failed to delete reminder: ${e.toString()}');
    }
  }
}

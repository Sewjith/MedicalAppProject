import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabaseMedicine {
  final String id; 
  final String name;

  SupabaseMedicine({required this.id, required this.name});

  factory SupabaseMedicine.fromMap(Map<String, dynamic> map) {
    return SupabaseMedicine(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }
}

class SelectedMedicine {
  final String medicineId; 
  final String medicineName;
  String dosage;
  String frequency;
  int duration;
  String instructions;

  SelectedMedicine({
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions = "",
  });
}

class PrescriptionSelectorPage extends StatefulWidget {
  const PrescriptionSelectorPage(
      {super.key});

  @override
  _PrescriptionSelectorPageState createState() =>
      _PrescriptionSelectorPageState();
}

class _PrescriptionSelectorPageState extends State<PrescriptionSelectorPage> {
  List<SupabaseMedicine> _availableMedicines = [];
  final List<SelectedMedicine> _selectedMedicines = [];
  bool _isLoadingMedicines = true;
  bool _isSubmitting = false;

  final List<String> _dosageOptions = ['250 mg', '500 mg', '1000 mg', '10 mg', '20 mg', '40 mg', '80 mg', '2.5 mg', '5 mg', '200 mg', '400 mg', '600 mg', '850 mg', '100 mg'];
  final List<String> _frequencyOptions = [
    'Once a day',
    'Twice a day',
    'Three times a day',
    'As needed'
  ];
  final List<int> _durationOptions = [1, 3, 5, 7, 10, 14, 21, 28, 30];

  final String AppointmentId = 'e99ba947-ec69-4993-a245-ef443a6d4adb'; 
  final String PatientId = 'a5073dd2-a726-43e6-9a25-1454ac6dfda5'; // 


  final supabase = Supabase.instance.client;
  final uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
  }

  Future<void> _fetchMedicines() async {
    setState(() {
      _isLoadingMedicines = true;
    });
    try {
      final response = await supabase
          .from('medicines')
          .select('id, name')
          .order('name', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      setState(() {
        _availableMedicines =
            data.map((map) => SupabaseMedicine.fromMap(map)).toList();
        _isLoadingMedicines = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMedicines = false;
      });
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error fetching medicines: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ));
      }
    }
  }

  void _selectMedicine(SupabaseMedicine medicine) async {
    final SelectedMedicine? result = await showModalBottomSheet<SelectedMedicine>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return MedicineOptionsSheet(
          medicineName: medicine.name,
          medicineId: medicine.id,
          dosageOptions: _dosageOptions,
          frequencyOptions: _frequencyOptions,
          durationOptions: _durationOptions,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedMedicines.add(result);
      });
    }
  }

  Future<void> _printPrescription([List<SelectedMedicine>? medicines]) async {
    final List<SelectedMedicine> listToPrint = medicines ?? _selectedMedicines;

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Prescription',
                    style: pw.TextStyle(
                        fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                ...listToPrint.map((item) => pw.Text(
                    '${item.medicineName} - ${item.dosage}, ${item.frequency}, for ${item.duration} days.\nNotes: ${item.instructions}',
                    style: const pw.TextStyle(fontSize: 14))),
              ]);
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _submitPrescription() async {

    if (_selectedMedicines.isEmpty) return;

    final List<SelectedMedicine> submittedMedicines = List.from(_selectedMedicines);

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String uniquePrescriptionIdentifier =
          '${DateTime.now().millisecondsSinceEpoch}-${uuid.v4().substring(0, 8)}';

      final prescriptionInsertResponse = await supabase
          .from('prescriptions')
          .insert({
            'prescription_id': uniquePrescriptionIdentifier,
            'appointment_id': AppointmentId,
            'patient_id': PatientId, 
            'notes': '',
            'date_issued': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();


      final String newPrescriptionUUID = prescriptionInsertResponse['id'];


      final List<Map<String, dynamic>> prescriptionMedicinesData =
          submittedMedicines.map((med) {
        return {
          'prescription_id': newPrescriptionUUID,
          'medicine_id': med.medicineId,
          'dosage': med.dosage,
          'frequency': med.frequency,
          'duration': med.duration,
          'notes': med.instructions,
        };
      }).toList();

      await supabase
          .from('prescription_medicines')
          .insert(prescriptionMedicinesData);


      _showSubmissionDialog(
        success: true,
        medicinesToPrint: submittedMedicines,
      );

      setState(() {
          _selectedMedicines.clear();
      });


    } catch (e) {
      print('Supabase submission error: $e');
      _showSubmissionDialog(success: false, errorMessage: e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSubmissionDialog({
    required bool success,
    String? errorMessage,
    List<SelectedMedicine>? medicinesToPrint,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(success ? Icons.check_circle : Icons.error,
                    size: 60, color: success ? Colors.green : Colors.red),
                const SizedBox(height: 20),
                Text(
                  success ? "Prescription Submitted!" : "Submission Failed",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  success
                      ? "Your prescription has been saved. What would you like to do next?"
                      : "Could not save the prescription.\nError: ${errorMessage ?? 'Unknown error'}",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (success && medicinesToPrint != null) 
                       ElevatedButton(
                        onPressed: () {
                           Navigator.of(context).pop(); 
                           _printPrescription(medicinesToPrint); 
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 45),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Print",
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(100, 45),
                        backgroundColor: success ? Colors.grey : Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(success ? "Done" : "OK",
                          style: const TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Tool'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_selectedMedicines.isNotEmpty)
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _selectedMedicines.length,
                    itemBuilder: (context, index) {
                      final item = _selectedMedicines[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent.shade100,
                          child: Text(item.medicineName[0],
                              style: const TextStyle(color: Colors.blueAccent)),
                        ),
                        title: Text(item.medicineName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${item.dosage}, ${item.frequency}, for ${item.duration} days.\nNotes: ${item.instructions}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              _selectedMedicines.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
             if (_selectedMedicines.isNotEmpty) const SizedBox(height: 16),

            Expanded(
              flex: 3,
              child: Card(
                elevation: 4,
                 shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                child: _isLoadingMedicines
                    ? const Center(child: CircularProgressIndicator())
                    : _availableMedicines.isEmpty
                        ? const Center(child: Text('No medicines found.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _availableMedicines.length,
                            itemBuilder: (context, index) {
                              final medicine = _availableMedicines[index];
                              return ListTile(
                                title: Text(medicine.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                trailing: ElevatedButton.icon(
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Add'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                                  ),
                                  onPressed: () => _selectMedicine(medicine),
                                ),
                              );
                            },
                          ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_selectedMedicines.isEmpty || _isSubmitting)
                    ? null
                    : _submitPrescription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  disabledBackgroundColor: Colors.grey.shade400
                ),
                child: _isSubmitting
                    ? const SizedBox(
                         width: 24,
                         height: 24,
                         child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                       )
                    : const Text(
                        'Submit Prescription',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MedicineOptionsSheet extends StatefulWidget {
  final String medicineName;
  final String medicineId;
  final List<String> dosageOptions;
  final List<String> frequencyOptions;
  final List<int> durationOptions;

  const MedicineOptionsSheet({
    super.key,
    required this.medicineName,
    required this.medicineId,
    required this.dosageOptions,
    required this.frequencyOptions,
    required this.durationOptions,
  });

  @override
  _MedicineOptionsSheetState createState() => _MedicineOptionsSheetState();
}

class _MedicineOptionsSheetState extends State<MedicineOptionsSheet> {
  late String _selectedDosage;
  late String _selectedFrequency;
  late int _selectedDuration;
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDosage = widget.dosageOptions.isNotEmpty ? widget.dosageOptions.first : '';
    _selectedFrequency = widget.frequencyOptions.isNotEmpty ? widget.frequencyOptions.first : '';
    _selectedDuration = widget.durationOptions.isNotEmpty ? widget.durationOptions.first : 7;
  }

   @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configure ${widget.medicineName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            const Text('Dosage:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDosage,
              items: widget.dosageOptions
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() { _selectedDosage = value; });
                }
              },
              decoration: InputDecoration(
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              isExpanded: true,
            ),
            const SizedBox(height: 16),

             const Text('Frequency:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              items: widget.frequencyOptions
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() { _selectedFrequency = value; });
                }
              },
               decoration: InputDecoration(
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
               isExpanded: true,
            ),
            const SizedBox(height: 16),

             const Text('Duration (days):', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
             DropdownButtonFormField<int>(
              value: _selectedDuration,
              items: widget.durationOptions
                  .map((days) => DropdownMenuItem(value: days, child: Text('$days days')))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() { _selectedDuration = value; });
                }
              },
               decoration: InputDecoration(
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
               isExpanded: true,
            ),
            const SizedBox(height: 16),

             const Text('Instructions (optional):', style: TextStyle(fontWeight: FontWeight.w600)),
             const SizedBox(height: 8),
            TextFormField(
              controller: _instructionsController,
              decoration: InputDecoration(
                hintText: 'e.g., Take with food',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            SizedBox(
               width: double.infinity,
               height: 50,
               child: ElevatedButton(
                 onPressed: () {
                   Navigator.of(context).pop(
                     SelectedMedicine(
                       medicineId: widget.medicineId,
                       medicineName: widget.medicineName,
                       dosage: _selectedDosage,
                       frequency: _selectedFrequency,
                       duration: _selectedDuration,
                       instructions: _instructionsController.text.trim(),
                     ),
                   );
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.blueAccent,
                   foregroundColor: Colors.white,
                   shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(10)),
                 ),
                 child: const Text('Add to Prescription', style: TextStyle(fontSize: 16)),
               ),
             ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
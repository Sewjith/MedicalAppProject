import 'package:flutter/material.dart';
import '../../data/models/medicine_models.dart';

class MedicineOptionsSheet extends StatefulWidget {
  final String medicineName;
  final String medicineId;
  final List<String> dosageOptions;
  final List<String> frequencyOptions;
  final List<int> durationOptions;
  final String? initialDosage;
  final String? initialFrequency;
  final int? initialDuration;
  final String? initialInstructions;

  const MedicineOptionsSheet({
    super.key,
    required this.medicineName,
    required this.medicineId,
    required this.dosageOptions,
    required this.frequencyOptions,
    required this.durationOptions,
    this.initialDosage,
    this.initialFrequency,
    this.initialDuration,
    this.initialInstructions,
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
    _selectedDosage = widget.initialDosage ??
        (widget.dosageOptions.isNotEmpty ? widget.dosageOptions.first : '');
    _selectedFrequency = widget.initialFrequency ??
        (widget.frequencyOptions.isNotEmpty
            ? widget.frequencyOptions.first
            : '');
    _selectedDuration = widget.initialDuration ??
        (widget.durationOptions.isNotEmpty ? widget.durationOptions.first : 7);
    _instructionsController.text = widget.initialInstructions ?? '';
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
            const Text('Dosage:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDosage,
              items: widget.dosageOptions
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDosage = value);
                }
              },
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              isExpanded: true,
            ),
            const SizedBox(height: 16),
            const Text('Frequency:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              items: widget.frequencyOptions
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFrequency = value);
                }
              },
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              isExpanded: true,
            ),
            const SizedBox(height: 16),
            const Text('Duration (days):',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedDuration,
              items: widget.durationOptions
                  .map((days) =>
                      DropdownMenuItem(value: days, child: Text('$days days')))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDuration = value);
                }
              },
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              isExpanded: true,
            ),
            const SizedBox(height: 16),
            const Text('Instructions (optional):',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _instructionsController,
              decoration: InputDecoration(
                hintText: 'e.g., Take with food',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                child: Text(
                    (widget.initialDosage != null)
                        ? 'Update Prescription Item'
                        : 'Add to Prescription',
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

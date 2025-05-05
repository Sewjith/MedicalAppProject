import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/medicine_models.dart';
import '../../data/services/prescription_service.dart';
import '../../utils/pdf_utils.dart';
import '../widgets/available_medicines_list.dart';
import '../widgets/dialogs.dart';
import '../widgets/medicine_options_sheet.dart';
import '../widgets/selected_medicines_card.dart';

class PrescriptionSelectorPage extends StatefulWidget {
  const PrescriptionSelectorPage({super.key});

  @override
  _PrescriptionSelectorPageState createState() =>
      _PrescriptionSelectorPageState();
}

class _PrescriptionSelectorPageState extends State<PrescriptionSelectorPage> {
  List<SupabaseMedicine> _availableMedicines = [];
  final List<SelectedMedicine> _selectedMedicines = [];
  bool _isLoadingMedicines = false;
  bool _isSubmitting = false;
  bool _isProcessingMedicine = false;

  final List<String> _dosageOptions = [
    '250 mg',
    '500 mg',
    '1000 mg',
    '10 mg',
    '20 mg',
    '40 mg',
    '80 mg',
    '2.5 mg',
    '5 mg',
    '200 mg',
    '400 mg',
    '600 mg',
    '850 mg',
    '100 mg'
  ];
  final List<String> _frequencyOptions = [
    'Once a day',
    'Twice a day',
    'Three times a day',
    'As needed'
  ];
  final List<int> _durationOptions = [1, 3, 5, 7, 10, 14, 21, 28, 30];
  final List<String> _commonMedicineTypes = [
    'Tablet',
    'Capsule',
    'Pill',
    'Syrup',
    'Injection',
    'Cream',
    'Ointment',
    'Drops',
    'Inhaler',
    'Other'
  ];

  final String _appointmentId = 'aee1ad0b-6f8d-4dcf-9320-91f701a02376';
  final String _patientId = '235a194c-60aa-4846-b14b-d7bb5eaecf59';

  final PrescriptionService _prescriptionService = PrescriptionService();

  @override
  void initState() {
    super.initState();
    _handleFetchMedicines();
  }

  Future<void> _handleFetchMedicines() async {
    if (_isLoadingMedicines || _isProcessingMedicine) return;
    if (!mounted) return;
    setState(() => _isLoadingMedicines = true);

    try {
      final medicines = await _prescriptionService.fetchMedicines();
      if (!mounted) return;
      setState(() {
        _availableMedicines = medicines;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ));
        setState(() {
          _availableMedicines = [];
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingMedicines = false);
    }
  }

  // Add,edit anddelete available medicines
  Future<void> _handleAddNewMedicine() async {
    if (_isLoadingMedicines || _isProcessingMedicine) return;

    final result = await showAddMedicineDialog(
        context, _commonMedicineTypes, _availableMedicines);

    if (result != null && mounted) {
      if (mounted) setState(() => _isProcessingMedicine = true);
      try {
        await _prescriptionService.addNewMedicine(
            result['name'], result['type']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Medicine "${result['name']}" added.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessingMedicine = false);
          _handleFetchMedicines();
        }
      }
    }
  }

  Future<void> _handleEditMedicine(SupabaseMedicine medicine) async {
    if (_isLoadingMedicines || _isProcessingMedicine) return;

    final result = await showEditMedicineDialog(
        context, medicine, _commonMedicineTypes, _availableMedicines);

    if (result != null && mounted) {
      setState(() => _isProcessingMedicine = true);
      try {
        await _prescriptionService.editMedicine(
            medicine.id, result['name'], result['type']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Medicine "${medicine.name}" updated.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessingMedicine = false);
          _handleFetchMedicines();
        }
      }
    }
  }

  Future<void> _handleDeleteMedicine(SupabaseMedicine medicine) async {
    if (_isLoadingMedicines || _isProcessingMedicine) return;

    final confirmed =
        await showDeleteConfirmationDialog(context, medicine.name);

    if (confirmed == true && mounted) {
      setState(() => _isProcessingMedicine = true);
      try {
        await _prescriptionService.deleteMedicine(medicine.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Medicine "${medicine.name}" deleted.'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessingMedicine = false);
          _handleFetchMedicines();
        }
      }
    }
  }

  // Select,edit and remove selected medicines
  void _handleSelectMedicine(SupabaseMedicine medicine) async {
    if (_isLoadingMedicines || _isProcessingMedicine) return;

    final SelectedMedicine? result =
        await showModalBottomSheet<SelectedMedicine>(
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
    if (result != null && mounted) {
      setState(() {
        _selectedMedicines.add(result);
      });
    }
  }

  void _handleEditSelectedMedicine(int index) async {
    if (_isSubmitting) return; // Prevent edit while submitting
    final SelectedMedicine currentItem = _selectedMedicines[index];

    final SelectedMedicine? result =
        await showModalBottomSheet<SelectedMedicine>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return MedicineOptionsSheet(
          medicineName: currentItem.medicineName,
          medicineId: currentItem.medicineId,
          dosageOptions: _dosageOptions,
          frequencyOptions: _frequencyOptions,
          durationOptions: _durationOptions,
          initialDosage: currentItem.dosage,
          initialFrequency: currentItem.frequency,
          initialDuration: currentItem.duration,
          initialInstructions: currentItem.instructions,
        );
      },
    );
    if (result != null && mounted) {
      setState(() {
        _selectedMedicines[index] = result;
      });
    }
  }

  void _handleDeleteSelectedMedicine(int index) {
    if (_isSubmitting) return; // Prevent delete while submitting
    setState(() {
      _selectedMedicines.removeAt(index);
    });
  }

  // Submit and printing
  Future<void> _handleSubmitPrescription() async {
    if (_selectedMedicines.isEmpty ||
        _isSubmitting ||
        _isLoadingMedicines ||
        _isProcessingMedicine) return;

    final List<SelectedMedicine> medicinesToSubmit =
        List.from(_selectedMedicines); // Copy list before clearing

    setState(() => _isSubmitting = true);
    String? submitError;
    bool success = false;

    try {
      await _prescriptionService.submitPrescription(
        appointmentId: _appointmentId,
        patientId: _patientId,
        selectedMedicines: medicinesToSubmit,
      );
      success = true;
      if (mounted)
        setState(() => _selectedMedicines.clear()); // Clear list
    } catch (e) {
      submitError = e.toString();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
      showSubmissionResultDialog(
        context: context,
        success: success,
        errorMessage: submitError,
        medicinesToPrint: success
            ? medicinesToSubmit
            : null,
        onPrint: () =>
            _handlePrintPrescription(medicinesToSubmit),
      );
    }
  }

  Future<void> _handlePrintPrescription(
      List<SelectedMedicine> medicinesToPrint) async {
    try {
      final pdfBytes =
          await PdfUtils.generatePrescriptionPdfBytes(medicinesToPrint);
      await PdfUtils.printPdfBytes(pdfBytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error generating PDF for print: $e'),
          backgroundColor: Colors.redAccent,
        ));
      }
      print("Error preparing PDF for print: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton( // Added explicit leading with correct logic
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/d_dashboard'); // Fallback to doctor dashboard
            }
          },
          color: Colors.white, // Assuming white icon for this AppBar
        ),
        title: const Text('Prescription Tool'),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (_isProcessingMedicine)
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))),
            )
          else
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add New Medicine',
              // Disable Add button while loading or submitting
              onPressed: (_isLoadingMedicines || _isSubmitting)
                  ? null
                  : _handleAddNewMedicine,
            ),
          const SizedBox(width: 8),
        ],
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
            SelectedMedicinesCard(
              selectedMedicines: _selectedMedicines,
              isSubmitting: _isSubmitting,
              onEdit: _handleEditSelectedMedicine,
              onDelete: _handleDeleteSelectedMedicine,
            ),
            if (_selectedMedicines.isNotEmpty) const SizedBox(height: 16),

            AvailableMedicinesList(
              isLoading: _isLoadingMedicines,
              isProcessing: _isProcessingMedicine,
              availableMedicines: _availableMedicines,
              onRefresh: _handleFetchMedicines,
              onSelectMedicine: _handleSelectMedicine,
              onEditMedicine: _handleEditMedicine,
              onDeleteMedicine: _handleDeleteMedicine,
            ),
            const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_selectedMedicines.isEmpty ||
                        _isSubmitting ||
                        _isLoadingMedicines ||
                        _isProcessingMedicine)
                    ? null
                    : _handleSubmitPrescription,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    disabledBackgroundColor: Colors.grey.shade400),
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

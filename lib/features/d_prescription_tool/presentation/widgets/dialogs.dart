import 'package:flutter/material.dart';
import '../../data/models/medicine_models.dart';

// Add medicine dialog
Future<Map<String, dynamic>?> showAddMedicineDialog(
    BuildContext context,
    List<String> commonMedicineTypes,
    List<SupabaseMedicine> existingMedicines) async {
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedType;

  return showDialog<Map<String, dynamic>?>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Add New Medicine'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Enter medicine name',
                      labelText: 'Medicine Name *',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Please enter a medicine name';
                      bool exists = existingMedicines.any((m) =>
                          m.name.trim().toLowerCase() ==
                          value.trim().toLowerCase());
                      if (exists) return 'This medicine name already exists';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    hint: const Text('Select Type (Optional)'),
                    isExpanded: true,
                    items: commonMedicineTypes.map((String type) {
                      return DropdownMenuItem<String>(
                          value: type, child: Text(type));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setDialogState(() => selectedType = newValue);
                    },
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(null),
            ), // Return null on cancel
            ElevatedButton(
              child: const Text('Add Medicine'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Return map of data on success
                  Navigator.of(context).pop({
                    'name': nameController.text.trim(),
                    'type': selectedType
                  });
                }
              },
            ),
          ],
        );
      });
    },
  );
}

// Edit medicine dialog
Future<Map<String, dynamic>?> showEditMedicineDialog(
    BuildContext context,
    SupabaseMedicine medicine, // Pass the medicine to edit
    List<String> commonMedicineTypes,
    List<SupabaseMedicine> existingMedicines) async {
  final TextEditingController nameController =
      TextEditingController(text: medicine.name);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedType =
      commonMedicineTypes.contains(medicine.type) ? medicine.type : null;
  if (medicine.type != null && !commonMedicineTypes.contains(medicine.type)) {
    selectedType = null;
  }

  return showDialog<Map<String, dynamic>?>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Edit Medicine'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Medicine Name *',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Please enter a medicine name';
                      bool exists = existingMedicines.any((m) =>
                          m.id != medicine.id &&
                          m.name.trim().toLowerCase() ==
                              value.trim().toLowerCase());
                      if (exists) return 'Another medicine has this name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    hint: const Text('Select Type (Optional)'),
                    isExpanded: true,
                    items: commonMedicineTypes.map((String type) {
                      return DropdownMenuItem<String>(
                          value: type, child: Text(type));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setDialogState(() => selectedType = newValue);
                    },
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            ElevatedButton(
              child: const Text('Save Changes'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop({
                    'name': nameController.text.trim(),
                    'type': selectedType
                  });
                }
              },
            ),
          ],
        );
      });
    },
  );
}

// Delete confirmation dialog
Future<bool?> showDeleteConfirmationDialog(
    BuildContext context, String medicineName) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  'Are you sure you want to delete the medicine "$medicineName"?'),
              const Text('This action cannot be undone.',
                  style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

// Submission result dialog
void showSubmissionResultDialog(
    {required BuildContext context,
    required bool success,
    String? errorMessage,
    List<SelectedMedicine>? medicinesToPrint,
    required Function() onPrint // Pass print function
    }) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                success
                    ? "Your prescription has been saved."
                    : "Could not save the prescription.\nError: ${errorMessage ?? 'Unknown error'}",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                success ? "What would you like to do next?" : "",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (success &&
                      medicinesToPrint != null &&
                      medicinesToPrint.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onPrint();
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
                      backgroundColor:
                          success ? Colors.grey : Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(success ? "Done" : "OK",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white)),
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

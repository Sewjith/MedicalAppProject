import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AddReportPage extends StatefulWidget {
  const AddReportPage({super.key});

  @override
  _AddReportPageState createState() => _AddReportPageState();
}

class _AddReportPageState extends State<AddReportPage> {
  final _formKey = GlobalKey<FormState>();

  // Variables for form data
  String? documentTitle;
  String? documentType;
  String? confidentialityLevel;
  String? category;
  File? selectedFile;
  DateTime? recordDate;
  String? issuingAuthority;
  String? notesDescription;

  // Function to pick a file (from gallery, camera, or file system)
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  // Function to pick an image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        selectedFile = File(pickedFile.path);
      });
    }
  }

  // Function to pick a date
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != recordDate) {
      setState(() {
        recordDate = pickedDate;
      });
    }
  }

  // Function to submit the form
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting Report...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        title: const Text('Add Report'),
        backgroundColor: const Color(0xFF2260FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Document Title
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Document Title',
                    filled: true,
                    fillColor: const Color(0xFFCAD6FF), // Light blue background
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Curved corners
                    ),
                  ),
                  onSaved: (value) => documentTitle = value,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter a document title'
                      : null,
                ),
                const SizedBox(height: 10),

                // Document Type
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Document Type',
                    filled: true,
                    fillColor: const Color(0xFFCAD6FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSaved: (value) => documentType = value,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter a document type'
                      : null,
                ),
                const SizedBox(height: 10),

                // Confidentiality Level
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confidentiality Level',
                    filled: true,
                    fillColor: const Color(0xFFCAD6FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSaved: (value) => confidentialityLevel = value,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter a confidentiality level'
                      : null,
                ),
                const SizedBox(height: 10),

                // Category (Dropdown)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: const Color(0xFFCAD6FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: category,
                  onChanged: (value) => setState(() => category = value),
                  items: <String>[
                    'Medical History',
                    'Appointments',
                    'Lab Reports',
                    'Vaccinations',
                    'Emergency Data',
                    'Dental & Vision',
                    'Other'
                  ]
                      .map((String value) => DropdownMenuItem<String>(
                          value: value, child: Text(value)))
                      .toList(),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please select a category'
                      : null,
                ),
                const SizedBox(height: 10),

                // Upload File
                TextButton(
                  onPressed: _pickFile,
                  child: const Text(
                    'Upload File',
                    style: TextStyle(color: Color(0xFF2260FF)), // Blue text
                  ),
                ),
                if (selectedFile != null)
                  Text('File selected: ${selectedFile?.path.split('/').last}'),
                const SizedBox(height: 10),

                // Date of Record
                Row(
                  children: [
                    const Text('Date of Record: '),
                    TextButton(
                      onPressed: () => _pickDate(context),
                      child: Text(
                        recordDate == null
                            ? 'Pick a Date'
                            : recordDate!.toLocal().toString().split(' ')[0],
                        style: const TextStyle(
                            color: Color(0xFF2260FF)), // Blue text
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Issuing Authority
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Issuing Authority',
                    filled: true,
                    fillColor: const Color(0xFFCAD6FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSaved: (value) => issuingAuthority = value,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter the issuing authority'
                      : null,
                ),
                const SizedBox(height: 10),

                // Notes / Description
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Notes / Description',
                    filled: true,
                    fillColor: const Color(0xFFCAD6FF),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 5,
                  onSaved: (value) => notesDescription = value,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter a description'
                      : null,
                ),
                const SizedBox(height: 20),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF2260FF), // Blue background
                      foregroundColor: Colors.white, // White text
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                      ),
                    ),
                    child: const Text('Submit Report'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

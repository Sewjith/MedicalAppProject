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

  // Function to submit the form (you can handle the data submission here)
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Simulate submission (print or send data to backend, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting Report...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  decoration: const InputDecoration(
                    labelText: 'Document Title',
                  ),
                  onSaved: (value) {
                    documentTitle = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a document title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Document Type
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Document Type',
                  ),
                  onSaved: (value) {
                    documentType = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a document type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Confidentiality Level
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Confidentiality Level',
                  ),
                  onSaved: (value) {
                    confidentialityLevel = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a confidentiality level';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Category (Dropdown)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  value: category,
                  onChanged: (value) {
                    setState(() {
                      category = value;
                    });
                  },
                  items: <String>[
                    'Medical History',
                    'Appointments',
                    'Lab Reports',
                    'Vaccinations',
                    'Emergency Data',
                    'Dental & Vision',
                    'Other',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Upload File
                TextButton(
                  onPressed: _pickFile,
                  child: const Text('Upload File'),
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
                      child: Text(recordDate == null
                          ? 'Pick a Date'
                          : recordDate!.toLocal().toString().split(' ')[0]),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Issuing Authority
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Issuing Authority',
                  ),
                  onSaved: (value) {
                    issuingAuthority = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the issuing authority';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Notes / Description (Large TextBox)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Notes / Description',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  onSaved: (value) {
                    notesDescription = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Submit Button
                Center(
                    child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2260FF),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

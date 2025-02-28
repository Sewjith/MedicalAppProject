import 'package:flutter/material.dart';

class ReportUploadPage extends StatefulWidget {
  const ReportUploadPage({super.key});

  @override
  _ReportUploadPageState createState() => _ReportUploadPageState();
}

class _ReportUploadPageState extends State<ReportUploadPage> {
  final _formKey = GlobalKey<FormState>();
  String? reportTitle;
  String? reportFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Upload'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Report Title'),
                onSaved: (value) => reportTitle = value,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter report title' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Upload File'),
                onSaved: (value) => reportFile = value,
                validator: (value) =>
                    value!.isEmpty ? 'Please upload a file' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Handle file upload and saving data
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Report uploaded')));
    }
  }
}

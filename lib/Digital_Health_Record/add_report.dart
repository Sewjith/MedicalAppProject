import 'package:flutter/material.dart';
import 'H_Record_backend.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _backend = HealthRecordBackend();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _category, _type, _level = 'medium';
  bool _isSubmitting = false;
  DateTime _recordDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Health Record'),
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
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration('Record Title'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a title' : null,
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: _inputDecoration('Description (Optional)'),
                  maxLines: 5,
                  maxLength: 500,
                ),
                const SizedBox(height: 16),
                _buildCategoryDropdown(),
                const SizedBox(height: 16),
                _buildTypeDropdown(),
                const SizedBox(height: 16),
                _buildLevelDropdown(),
                const SizedBox(height: 16),
                _buildDatePicker(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFCAD6FF).withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _category,
      decoration: _inputDecoration('Category'),
      items: const [
        DropdownMenuItem(
            value: 'Medical History', child: Text('Medical History')),
        DropdownMenuItem(value: 'Appointments', child: Text('Appointments')),
        DropdownMenuItem(value: 'Lab Results', child: Text('Lab Results')),
        DropdownMenuItem(value: 'Vaccinations', child: Text('Vaccinations')),
        DropdownMenuItem(value: 'Emergency', child: Text('Emergency')),
        DropdownMenuItem(
            value: 'Dental & Vision', child: Text('Dental & Vision')),
      ],
      onChanged: (value) => setState(() => _category = value),
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _type,
      decoration: _inputDecoration('Record Type'),
      items: const [
        DropdownMenuItem(value: 'Report', child: Text('Report')),
        DropdownMenuItem(value: 'Prescription', child: Text('Prescription')),
        DropdownMenuItem(value: 'Note', child: Text('Note')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      onChanged: (value) => setState(() => _type = value),
      validator: (value) => value == null ? 'Please select a type' : null,
    );
  }

  Widget _buildLevelDropdown() {
    return DropdownButtonFormField<String>(
      value: _level,
      decoration: _inputDecoration('Confidentiality Level'),
      items: const [
        DropdownMenuItem(value: 'low', child: Text('Low')),
        DropdownMenuItem(value: 'medium', child: Text('Medium')),
        DropdownMenuItem(value: 'high', child: Text('High')),
      ],
      onChanged: (value) => setState(() => _level = value),
    );
  }

  Widget _buildDatePicker() {
    return InputDecorator(
      decoration: _inputDecoration('Record Date'),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.calendar_today, color: Color(0xFF2260FF)),
        title: Text(DateFormat('MMM dd, yyyy').format(_recordDate)),
        onTap: () => _pickDate(context),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2260FF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Submit Record', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _recordDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() => _recordDate = pickedDate);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _backend.addHealthRecord(
        title: _titleController.text.trim(),
        category: _category!,
        type: _type!,
        level: _level!,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        recordDate: _recordDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record added successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Submit error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }
}

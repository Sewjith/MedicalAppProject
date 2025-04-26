import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';
import 'H_Record_backend.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class AddReportScreen extends StatefulWidget {
  final Map<String, dynamic>? existingRecord;

  const AddReportScreen({super.key, this.existingRecord});

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
  File? _attachment;
  String? _currentAttachmentUrl;
  bool _removeAttachment = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecord != null) {
      _titleController.text = widget.existingRecord!['title'] ?? '';
      _descController.text = widget.existingRecord!['description'] ?? '';
      _category = widget.existingRecord!['category'];
      _type = widget.existingRecord!['type'];
      _level = widget.existingRecord!['level'] ?? 'medium';
      _currentAttachmentUrl = widget.existingRecord!['doc_link'];
      if (widget.existingRecord!['record_date'] != null) {
        _recordDate = DateTime.parse(widget.existingRecord!['record_date']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRecord == null
            ? 'Add Health Record'
            : 'Edit Health Record'),
        backgroundColor: const Color(0xFF2260FF),
        actions: [
          if (widget.existingRecord != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
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
                const SizedBox(height: 16),
                _buildAttachmentSection(),
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

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Attachment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_currentAttachmentUrl != null && !_removeAttachment)
          _buildAttachmentChip(_currentAttachmentUrl!, true),
        if (_attachment != null) _buildAttachmentChip(_attachment!.path, false),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Add Attachment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2260FF).withOpacity(0.1),
                foregroundColor: const Color(0xFF2260FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_currentAttachmentUrl != null && !_removeAttachment)
              TextButton(
                onPressed: () {
                  setState(() {
                    _removeAttachment = true;
                  });
                },
                child:
                    const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttachmentChip(String filePath, bool isExisting) {
    final fileName =
        isExisting ? path.basename(filePath) : path.basename(filePath);
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getAttachmentIcon(fileName),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            fileName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 12),
          ),
          if (!isExisting)
            Text(
              ' (${_formatFileSize(File(filePath).lengthSync())})',
              style: const TextStyle(fontSize: 10),
            ),
        ],
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {
        setState(() {
          if (isExisting) {
            _removeAttachment = true;
          } else {
            _attachment = null;
          }
        });
      },
    );
  }

  IconData _getAttachmentIcon(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    if (ext == '.pdf') return Icons.picture_as_pdf;
    if (ext == '.jpg' || ext == '.jpeg' || ext == '.png') return Icons.image;
    if (ext == '.doc' || ext == '.docx') return Icons.description;
    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
            : Text(
                widget.existingRecord == null
                    ? 'Submit Record'
                    : 'Update Record',
                style: const TextStyle(fontSize: 16),
              ),
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

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _attachment = File(result.files.single.path!);
          _removeAttachment = false;
        });
      }
    } catch (e) {
      debugPrint('File picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      if (widget.existingRecord == null) {
        // Add new record
        await _backend.addHealthRecord(
          title: _titleController.text.trim(),
          category: _category!,
          type: _type!,
          level: _level!,
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          recordDate: _recordDate,
          attachment: _attachment,
        );
      } else {
        // Update existing record
        await _backend.updateRecord(
          id: widget.existingRecord!['id'],
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          category: _category!,
          type: _type!,
          level: _level!,
          recordDate: _recordDate,
          newAttachment: _attachment,
          removeAttachment: _removeAttachment,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingRecord == null
                ? 'Record added successfully!'
                : 'Record updated successfully!'),
          ),
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

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
            'Are you sure you want to delete this record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _backend.deleteRecord(widget.existingRecord!['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record deleted successfully')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting record: ${e.toString()}')),
          );
        }
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

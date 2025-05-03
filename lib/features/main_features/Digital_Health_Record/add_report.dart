import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/common/cubits/user_session/app_user_cubit.dart';
import '../../../core/themes/color_palette.dart';
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
  String? _patientId;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializePatientId();
    if (widget.existingRecord != null) {
      _populateForm(widget.existingRecord!);
    }
  }

   void _initializePatientId() {
     WidgetsBinding.instance.addPostFrameCallback((_) {
        final userState = context.read<AppUserCubit>().state;
        if (userState is AppUserLoggedIn && userState.user.role == 'patient') {
           if (mounted) {
              setState(() {
                 _patientId = userState.user.uid;
                 _isInitializing = false;
              });
           }
        } else {
          if (mounted) {
            setState(() => _isInitializing = false);
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Error: Patient not logged in.')),
             );
             context.pop(); // Go back if patient ID not found
          }
        }
     });
   }


  void _populateForm(Map<String, dynamic> record) {
    _titleController.text = record['title'] ?? '';
    _descController.text = record['description'] ?? '';
    _category = record['category'];
    _type = record['type'];
    _level = record['level'] ?? 'medium';
    _currentAttachmentUrl = record['doc_link'];
    if (record['record_date'] != null) {
      try {
         _recordDate = DateTime.parse(record['record_date']);
      } catch(e) {
         _recordDate = DateTime.now(); // fallback
         debugPrint("Error parsing existing record date: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
     if (_isInitializing) {
       return Scaffold(
         appBar: AppBar(title: const Text('Loading...')),
         body: const Center(child: CircularProgressIndicator()),
       );
     }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRecord == null
            ? 'Add Health Record'
            : 'Edit Health Record'),
        backgroundColor: const Color(0xFF2260FF),
        foregroundColor: Colors.white,
        actions: [
          if (widget.existingRecord != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              tooltip: 'Delete Record',
              onPressed: _isSubmitting ? null : _confirmDelete,
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
                  decoration: _inputDecoration('Record Title*'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a title' : null,
                  maxLength: 100,
                   enabled: !_isSubmitting,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: _inputDecoration('Description (Optional)'),
                  maxLines: 5,
                  maxLength: 500,
                   enabled: !_isSubmitting,
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
      decoration: _inputDecoration('Category*'),
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
      onChanged: _isSubmitting ? null : (value) => setState(() => _category = value),
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _type,
      decoration: _inputDecoration('Record Type*'),
      items: const [
        DropdownMenuItem(value: 'Report', child: Text('Report')),
        DropdownMenuItem(value: 'Prescription', child: Text('Prescription')),
        DropdownMenuItem(value: 'Note', child: Text('Note')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      onChanged: _isSubmitting ? null : (value) => setState(() => _type = value),
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
       onChanged: _isSubmitting ? null : (value) => setState(() => _level = value),
    );
  }

  Widget _buildDatePicker() {
    return InputDecorator(
      decoration: _inputDecoration('Record Date*'),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.calendar_today, color: Color(0xFF2260FF)),
        title: Text(DateFormat('MMM dd, yyyy').format(_recordDate)),
        onTap: _isSubmitting ? null : () => _pickDate(context),
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
              onPressed: _isSubmitting ? null : _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_attachment != null || (_currentAttachmentUrl != null && !_removeAttachment)
                        ? 'Change Attachment'
                        : 'Add Attachment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2260FF).withOpacity(0.1),
                foregroundColor: const Color(0xFF2260FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Spacer(),
            if (_currentAttachmentUrl != null && !_removeAttachment)
              TextButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Remove', style: TextStyle(color: Colors.red)),
                onPressed: _isSubmitting ? null : () {
                  setState(() {
                    _removeAttachment = true;
                    _attachment = null; // Clear any newly selected file too
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttachmentChip(String filePath, bool isExisting) {
    final fileName = path.basename(filePath);
    return Chip(
      avatar: Icon( _getAttachmentIcon(fileName), size: 16, color: AppPallete.primaryColor, ),
      label: Text(
        fileName,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: const TextStyle(fontSize: 12),
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: _isSubmitting ? null : () {
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
    if (['.jpg', '.jpeg', '.png', '.gif', '.bmp'].contains(ext)) return Icons.image;
    if (['.doc', '.docx'].contains(ext)) return Icons.description;
    return Icons.insert_drive_file;
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
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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
      firstDate: DateTime(1900), // Allow older dates
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      setState(() => _recordDate = pickedDate);
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null && mounted) {
        setState(() {
          _attachment = File(result.files.single.path!);
          _removeAttachment = false; // Selecting a new file overrides removal intention
           _currentAttachmentUrl = null; // Clear existing URL display if new file selected
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
    if (_patientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Error: Patient ID not available.')),
         );
         return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (widget.existingRecord == null) {
        // Add new record
        await _backend.addHealthRecord(
          patientId: _patientId!,
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
           patientId: _patientId!,
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
             backgroundColor: Colors.green,
          ),
        );
        context.pop(true); // Return true to indicate success
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
     if (_patientId == null || widget.existingRecord == null) return;

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
       setState(() => _isSubmitting = true); // Show loading during delete
      try {
        await _backend.deleteRecord(_patientId!, widget.existingRecord!['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record deleted successfully')),
          );
          context.pop(true); // Indicate success/change
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting record: ${e.toString()}')),
          );
        }
      } finally {
         if (mounted) {
           setState(() => _isSubmitting = false);
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

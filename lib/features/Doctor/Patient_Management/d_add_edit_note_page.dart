import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'd_patient_notes_db.dart'; // Import the DB service

class AddEditNotePage extends StatefulWidget {
  final String patientId;
  final String doctorId;
  final Map<String, dynamic>? noteData; // Optional: for editing

  const AddEditNotePage({
    Key? key,
    required this.patientId,
    required this.doctorId,
    this.noteData,
  }) : super(key: key);

  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noteController = TextEditingController();
  final DoctorPatientNotesDB _db = DoctorPatientNotesDB();
  bool _isSaving = false;
  bool get _isEditing => widget.noteData != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _noteController.text = widget.noteData!['note_content'] ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        // Update existing note
        await _db.updatePatientNote(
          noteId: widget.noteData!['note_id'],
          doctorId: widget.doctorId,
          updatedContent: _noteController.text,
        );
      } else {
        // Add new note
        await _db.addPatientNote(
          doctorId: widget.doctorId,
          patientId: widget.patientId,
          noteContent: _noteController.text,
          // Optionally link appointmentId if available/needed
          // appointmentId: widget.appointmentId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Note updated!' : 'Note added!'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop with result=true to indicate success
        context.pop(true);
      }
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Error saving note: ${e.toString()}'),
             backgroundColor: Colors.red,
           ),
         );
       }
    } finally {
       if (mounted) {
         setState(() => _isSaving = false);
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'Add Note'),
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: AppPallete.whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.close), // Use close icon
          onPressed: () => context.pop(false), // Pop with false (no change)
        ),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save),
            tooltip: 'Save Note',
            onPressed: _isSaving ? null : _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _noteController,
                  maxLines: null, // Allows unlimited lines
                  expands: true, // Fills available space
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Enter your notes here...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Note content cannot be empty.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Optional: Display created/updated timestamps if editing
              if (_isEditing)
                Text(
                  'Last Updated: ${_formatDateTime(widget.noteData!['updated_at'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                )
            ],
          ),
        ),
      ),
    );
  }

   String _formatDateTime(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }
}

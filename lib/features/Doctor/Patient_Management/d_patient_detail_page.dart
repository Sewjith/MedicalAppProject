import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'd_patient_notes_db.dart'; 

class DoctorPatientDetailPage extends StatefulWidget {
  final String patientId;
  final String doctorId; // Passed via extra

  const DoctorPatientDetailPage({
    Key? key,
    required this.patientId,
    required this.doctorId,
  }) : super(key: key);

  @override
  _DoctorPatientDetailPageState createState() =>
      _DoctorPatientDetailPageState();
}

class _DoctorPatientDetailPageState extends State<DoctorPatientDetailPage>
    with SingleTickerProviderStateMixin {
  final DoctorPatientNotesDB _db = DoctorPatientNotesDB();
  late TabController _tabController;

  Map<String, dynamic>? _patientData;
  List<Map<String, dynamic>> _medicalHistory = [];
  List<Map<String, dynamic>> _consultationHistory = [];
  List<Map<String, dynamic>> _patientNotes = [];

  bool _isLoadingProfile = true;
  bool _isLoadingHistory = true;
  bool _isLoadingConsultations = true;
  bool _isLoadingNotes = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (mounted) { 
        setState(() {}); 
      }
    });

    _loadAllData();
  }

  @override
  void dispose() {
 
    _tabController.removeListener(() {
       if (mounted) {
         setState(() {});
       }
    });

    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProfile = true;
      _isLoadingHistory = true;
      _isLoadingConsultations = true;
      _isLoadingNotes = true;
      _errorMessage = null;
    });

    try {
      // Fetch all data concurrently
      final results = await Future.wait([
        _db.getPatientDetails(widget.patientId),
        _db.getPatientMedicalHistory(widget.patientId),
        _db.getPatientConsultationHistory(
            doctorId: widget.doctorId, patientId: widget.patientId),
        _db.getPatientNotes(
            doctorId: widget.doctorId, patientId: widget.patientId),
      ]);

      if (!mounted) return;

      setState(() {
        _patientData = results[0] as Map<String, dynamic>?;
        _medicalHistory = List<Map<String, dynamic>>.from(results[1] as List);
        _consultationHistory = List<Map<String, dynamic>>.from(results[2] as List);
        _patientNotes = List<Map<String, dynamic>>.from(results[3] as List);

        _isLoadingProfile = false;
        _isLoadingHistory = false;
        _isLoadingConsultations = false;
        _isLoadingNotes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to load patient data: ${e.toString()}";
        _isLoadingProfile = false;
        _isLoadingHistory = false;
        _isLoadingConsultations = false;
        _isLoadingNotes = false;
      });
    }
  }

  Future<void> _refreshNotes() async {
    if (!mounted) return;
     setState(() => _isLoadingNotes = true);
    try {
       final notes = await _db.getPatientNotes(
           doctorId: widget.doctorId, patientId: widget.patientId);
       if (!mounted) return;
       setState(() {
          _patientNotes = notes;
          _isLoadingNotes = false;
       });
    } catch (e) {
       if (!mounted) return;
       setState(() => _isLoadingNotes = false);
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error refreshing notes: ${e.toString()}')),
       );
    }
  }

  void _navigateToAddNote() {
     context.push('/doctor/patient-note/add', extra: {
       'patientId': widget.patientId,
       'doctorId': widget.doctorId,
     }).then((result) {
       // Refresh notes if a note was successfully added (result == true)
       if (result == true) {
         _refreshNotes();
       }
     });
  }

   void _navigateToEditNote(Map<String, dynamic> note) {
     context.push('/doctor/patient-note/edit/${note['note_id']}', extra: {
       'noteData': note, // Pass existing note data
       'patientId': widget.patientId,
       'doctorId': widget.doctorId,
     }).then((result) {
       // Refresh notes if a note was successfully updated (result == true)
       if (result == true) {
         _refreshNotes();
       }
     });
  }

   Future<void> _confirmDeleteNote(String noteId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _db.deletePatientNote(noteId: noteId, doctorId: widget.doctorId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note deleted')));
          _refreshNotes(); // Refresh the list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting note: $e')));
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final patientName = _patientData != null
        ? '${_patientData!['first_name'] ?? ''} ${_patientData!['last_name'] ?? ''}'.trim()
        : 'Patient Details';

    return Scaffold(
      appBar: AppBar(
        title: Text(patientName.isEmpty ? 'Patient Details' : patientName),
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: AppPallete.whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppPallete.whiteColor,
          unselectedLabelColor: AppPallete.whiteColor.withOpacity(0.7),
          indicatorColor: AppPallete.whiteColor,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'History'), // Combined Medical & Consultation
            Tab(text: 'Notes'),
          ],
        ),
      ),
      body: _isLoadingProfile // Show loading if profile is still loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))))
              : _patientData == null
                  ? const Center(child: Text('Patient data not found.'))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProfileTab(_patientData!),
                        _buildHistoryTab(), // Combined history view
                        _buildNotesTab(),
                      ],
                    ),
  
      floatingActionButton: _tabController.index == 2 // Show FAB only on Notes tab
          ? FloatingActionButton(
              onPressed: _navigateToAddNote,
              tooltip: 'Add Note',
              backgroundColor: AppPallete.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

    );
  }

  // --- Tab Builder Widgets ---

  Widget _buildProfileTab(Map<String, dynamic> data) {
    final avatarUrl = data['avatar_url'] as String?;

    String dob = 'N/A';
    if (data['date_of_birth'] != null) {
        try {
            dob = DateFormat('yyyy-MM-dd').format(DateTime.parse(data['date_of_birth']));
        } catch (e) {
            debugPrint("Error parsing DOB '${data['date_of_birth']}': $e");
            // Keep dob as 'N/A' or handle as appropriate
        }
    }


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
               backgroundImage: avatarUrl != null
                   ? CachedNetworkImageProvider(avatarUrl)
                   : const AssetImage('assets/images/patient.jpeg') as ImageProvider,
               onBackgroundImageError: (_, __) { debugPrint("Error loading patient image: $avatarUrl"); },
               child: avatarUrl == null ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard('Basic Information', [
            _buildDetailRow('Name', '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim()),
            _buildDetailRow('Age', data['age']?.toString() ?? 'N/A'),
            _buildDetailRow('Gender', data['gender'] ?? 'N/A'),
            _buildDetailRow('Date of Birth', dob),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Contact Information', [
            _buildDetailRow('Email', data['email'] ?? 'N/A'),
            _buildDetailRow('Phone', data['phone_number'] ?? 'N/A'),
            _buildDetailRow('Address', data['address'] ?? 'N/A'),
          ]),
          // Add more sections as needed (e.g., Emergency Contact)
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView( // Use ListView for potentially long history
       padding: const EdgeInsets.all(16.0),
       children: [
          _buildSectionTitle('Medical History'),
          _isLoadingHistory
              ? const Center(child: CircularProgressIndicator())
              : _medicalHistory.isEmpty
                  ? const Padding( // Add padding for better spacing
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: Text('No medical history recorded.', style: TextStyle(color: AppPallete.greyColor))),
                    )
                  : Column(children: _medicalHistory.map(_buildMedicalHistoryCard).toList()),

          const SizedBox(height: 24),
          _buildSectionTitle('Consultation History'),
           _isLoadingConsultations
              ? const Center(child: CircularProgressIndicator())
              : _consultationHistory.isEmpty
                  ? const Padding( // Add padding
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: Text('No past consultations with you.', style: TextStyle(color: AppPallete.greyColor))),
                    )
                  : Column(children: _consultationHistory.map(_buildConsultationHistoryCard).toList()),
       ],
    );
  }

   Widget _buildNotesTab() {
    return RefreshIndicator(
      onRefresh: _refreshNotes,
      child: _isLoadingNotes
          ? const Center(child: CircularProgressIndicator())
          : _patientNotes.isEmpty
              ? LayoutBuilder( // Ensure "No notes" message is centered even if list is empty
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: const Center(child: Text('No notes added for this patient yet.', style: TextStyle(color: AppPallete.greyColor))),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _patientNotes.length,
                  itemBuilder: (context, index) {
                    final note = _patientNotes[index];
                    return _buildNoteCard(note);
                  },
                ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppPallete.primaryColor)),
            const Divider(height: 16, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
          Expanded(child: Text(value.isEmpty ? 'N/A' : value)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 12.0, top: 8.0), // Add top padding
       child: Text(
         title,
         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppPallete.primaryColor),
       ),
     );
  }

  Widget _buildMedicalHistoryCard(Map<String, dynamic> record) {
     return Card(
       margin: const EdgeInsets.only(bottom: 8),
       elevation: 1,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
       child: ListTile(
         leading: Icon(_getIconForType(record['type']), color: _getColorForType(record['type'])),
         title: Text(record['title'] ?? 'Untitled Record'),
         subtitle: Text('Category: ${record['category'] ?? 'N/A'} • Date: ${_formatDate(record['record_date'])}'),

       ),
     );
  }

  Widget _buildConsultationHistoryCard(Map<String, dynamic> appointment) {
     return Card(
       margin: const EdgeInsets.only(bottom: 8),
       elevation: 1,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
       child: ListTile(
         leading: Icon(Icons.calendar_today_outlined, color: AppPallete.primaryColor),
         title: Text('Consultation on ${_formatDate(appointment['appointment_date'])}'),
         subtitle: Text('Status: ${appointment['appointment_status'] ?? 'N/A'} • Time: ${appointment['appointment_time'] ?? 'N/A'}'),

       ),
     );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note['note_content'] ?? 'No content',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Added: ${_formatDateTime(note['created_at'])}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     IconButton(
                       icon: const Icon(Icons.edit_note, size: 20, color: Colors.blueGrey),
                       tooltip: 'Edit Note',
                       onPressed: () => _navigateToEditNote(note),
                       constraints: const BoxConstraints(), // Remove extra padding
                       padding: const EdgeInsets.symmetric(horizontal: 4),
                     ),
                     IconButton(
                       icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                       tooltip: 'Delete Note',
                       onPressed: () => _confirmDeleteNote(note['note_id']),
                       constraints: const BoxConstraints(), // Remove extra padding
                       padding: const EdgeInsets.symmetric(horizontal: 4),
                     ),
                  ],
                ),
              ],
            ),
             if (note['updated_at'] != null && note['updated_at'] != note['created_at'])
               Padding(
                 padding: const EdgeInsets.only(top: 4.0),
                 child: Text(
                   'Updated: ${_formatDateTime(note['updated_at'])}',
                   style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
                 ),
               ),
          ],
        ),
      ),
    );
  }


  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
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

  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'report': return Icons.description_outlined;
      case 'prescription': return Icons.medical_services_outlined;
      case 'note': return Icons.note_alt_outlined;
      default: return Icons.insert_drive_file_outlined;
    }
  }

  Color _getColorForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'report': return Colors.blue;
      case 'prescription': return Colors.green;
      case 'note': return Colors.orange;
      default: return Colors.grey;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:go_router/go_router.dart';   
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/common/cubits/user_session/app_user_cubit.dart'; 
import '../../../core/themes/color_palette.dart'; 
import 'H_Record_backend.dart';
import 'add_report.dart';
import 'package:flutter/foundation.dart';


class DigitalHealthRecordUI extends StatefulWidget {
  const DigitalHealthRecordUI({super.key});

  @override
  State<DigitalHealthRecordUI> createState() => _DigitalHealthRecordUIState();
}

class _DigitalHealthRecordUIState extends State<DigitalHealthRecordUI> {
  final _backend = HealthRecordBackend();
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;
  bool _showFavorites = false;
  String? _currentCategory;
  String? _patientId; // Added to store patient ID
  String? _errorMessage; // Added for error handling

  @override
  void initState() {
    super.initState();
    _initializePatientIdAndLoadRecords(); // Call the new initialization method
  }

  // Method to fetch patient ID and then load records
  void _initializePatientIdAndLoadRecords() {
     WidgetsBinding.instance.addPostFrameCallback((_) {
        final userState = context.read<AppUserCubit>().state;
        if (userState is AppUserLoggedIn && userState.user.role == 'patient') {
          _patientId = userState.user.uid;
          if (_patientId != null && _patientId!.isNotEmpty) {
            _loadRecords(); // Load records only after getting patient ID
          } else {
             if (mounted) {
               setState(() {
                  _isLoading = false;
                  _errorMessage = "Could not get patient ID.";
               });
             }
          }
        } else {
           if (mounted) {
             setState(() {
                _isLoading = false;
                _errorMessage = "Please log in as a patient to view records.";
             });
              // Optionally redirect if not a patient
              // context.go('/login');
           }
        }
     });
  }


  Future<void> _loadRecords() async {
    // Check if patientId is available before loading
    if (_patientId == null) {
       if (mounted) {
          setState(() {
             _isLoading = false;
             _errorMessage = _errorMessage ?? "Patient ID not available.";
          });
       }
       return;
    }

    if (!mounted) return;
    setState(() {
       _isLoading = true;
       _errorMessage = null; // Clear previous errors
    });

    try {
      // Pass the required patientId here
      _records = await _backend.getHealthRecords(
        patientId: _patientId!,
        favoritesOnly: _showFavorites,
        category: _currentCategory,
      );
    } catch (e) {
      debugPrint('Load records error: $e');
      _errorMessage = 'Error loading records: ${e.toString()}';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Health Records'),
        backgroundColor: const Color(0xFF2260FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: _showFavorites ? 'Show All Records' : 'Show Favorites Only',
            icon: Icon(_showFavorites ? Icons.favorite : Icons.favorite_border),
            // Disable button if patientId is not available
            onPressed: _patientId == null ? null : () {
              setState(() => _showFavorites = !_showFavorites);
              _loadRecords();
            },
          ),
        ],
      ),
      body: _buildBody(),
      // Disable FAB if patientId is not available
      floatingActionButton: _patientId == null
        ? null
        : FloatingActionButton(
            onPressed: _navigateToAddReport,
            backgroundColor: const Color(0xFF2260FF),
            tooltip: 'Add New Record',
            child: const Icon(Icons.add, color: Colors.white),
          ),
    );
  }

  Widget _buildBody() {
    // Show error if patientId is missing after initial check
    if (_patientId == null && !_isLoading) {
       return Center(
         child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_errorMessage ?? "Patient ID not found. Cannot load records.", style: TextStyle(color: Colors.red)),
         ),
       );
    }

    // Show loading or content
    return RefreshIndicator(
      onRefresh: _loadRecords, // Enable pull-to-refresh
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Ensure scroll works with RefreshIndicator
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterChips(),
            const SizedBox(height: 16),
            const Text('My Health Records:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildReportsContainer(),
            const SizedBox(height: 20),
            const Text('Categories:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildCategoryGrid(),
          ],
        ),
      ),
    );
  }

   Widget _buildFilterChips() {
     // Don't show filters if patient ID is not yet available
     if (_patientId == null) return const SizedBox.shrink();

     bool filtersActive = _currentCategory != null || _showFavorites;

     return Wrap(
       spacing: 8,
       children: [
         if (filtersActive)
           ActionChip(
             avatar: const Icon(Icons.clear, size: 16),
             label: const Text('Clear Filters'),
             onPressed: () {
               setState(() {
                 _currentCategory = null;
                 _showFavorites = false;
               });
               _loadRecords(); // Reload records with cleared filters
             },
           ),
         if (_currentCategory != null)
           Chip(
             label: Text('Category: $_currentCategory'),
             onDeleted: () {
               setState(() => _currentCategory = null);
               _loadRecords(); // Reload records without category filter
             },
           ),
         if (_showFavorites)
           Chip(
             avatar: const Icon(Icons.favorite, color: Colors.red, size: 16),
             label: const Text('Favorites'),
             onDeleted: () {
               setState(() => _showFavorites = false);
               _loadRecords(); // Reload records without favorite filter
             },
           ),
       ],
     );
   }

   Widget _buildReportsContainer() {
     double containerHeight = 250; // Default height
     if (!_isLoading && _records.isEmpty) {
       containerHeight = 100; // Smaller height when empty
     }

     return Container(
       constraints: BoxConstraints(minHeight: containerHeight), // Ensure minimum height
       width: double.infinity, // Take full width
       decoration: BoxDecoration(
         color: const Color(0xFFCAD6FF).withOpacity(0.3), // Lighter background
         borderRadius: BorderRadius.circular(16),
       ),
       padding: const EdgeInsets.all(10),
       child: _isLoading
           ? const Center(child: CircularProgressIndicator())
           : _records.isEmpty
               ? Center(
                   child: Text(
                     _currentCategory != null
                         ? 'No records found in "$_currentCategory"'
                         : _showFavorites
                             ? 'No favorite records found'
                             : 'No records found. Add one!',
                     textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600])
                   ),
                 )
               : ListView.builder(
                   shrinkWrap: true, // Adjust height to content
                   physics: const NeverScrollableScrollPhysics(), // Disable inner scrolling
                   itemCount: _records.length,
                   itemBuilder: (context, index) =>
                       _buildReportCard(_records[index]),
                 ),
     );
   }


   Widget _buildCategoryGrid() {
     // Don't show categories if patient ID is not yet available
     if (_patientId == null) return const SizedBox.shrink();

     const categories = [
       'Medical History',
       'Appointments',
       'Lab Results',
       'Vaccinations',
       'Emergency',
       'Dental & Vision',
     ];

     const icons = [
       Icons.history,
       Icons.calendar_today,
       Icons.note,
       Icons.local_hospital,
       Icons.emergency,
       Icons.visibility,
     ];

     return GridView.builder(
       shrinkWrap: true,
       physics: const NeverScrollableScrollPhysics(),
       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
         crossAxisCount: 2,
         crossAxisSpacing: 12,
         mainAxisSpacing: 12,
         childAspectRatio: 1.4, // Adjust aspect ratio if needed
       ),
       // Add 1 for the "Add Report" tile
       itemCount: categories.length + 1,
       itemBuilder: (context, index) {
         // If it's the last item, show the Add Report tile
         if (index == categories.length) {
           return _buildAddReportTile();
         }
         // Otherwise, show the category tile
         return _buildCategoryTile(categories[index], icons[index]);
       },
     );
   }

   Widget _buildCategoryTile(String category, IconData icon) {
     bool isActive = _currentCategory == category;
     return InkWell(
       onTap: () {
         setState(() => _currentCategory = category);
         _loadRecords(); // Load records for the selected category
       },
       child: Container(
         decoration: BoxDecoration(
           color: isActive ? const Color(0xFF003A9E) : const Color(0xFF2260FF), // Highlight active category
           borderRadius: BorderRadius.circular(16),
           border: isActive ? Border.all(color: Colors.white, width: 2) : null, // Border for active
         ),
         padding: const EdgeInsets.all(12),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(icon, color: Colors.white, size: 40),
             const SizedBox(height: 8),
             Text(
               category,
               style: const TextStyle(color: Colors.white),
               textAlign: TextAlign.center,
             ),
           ],
         ),
       ),
     );
   }

   // Tile specifically for adding a new report
   Widget _buildAddReportTile() {
     return InkWell(
       onTap: _navigateToAddReport,
       child: Container(
         decoration: BoxDecoration(
           // Use a slightly different style to indicate action
           color: const Color(0xFF2260FF).withOpacity(0.7),
           borderRadius: BorderRadius.circular(16),
           border: Border.all(color: Colors.white.withOpacity(0.5), width: 1)
         ),
         padding: const EdgeInsets.all(12),
         child: const Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(Icons.add_circle_outline, color: Colors.white, size: 40),
             SizedBox(height: 8),
             Text(
               'Add New Report',
               style: TextStyle(color: Colors.white),
               textAlign: TextAlign.center,
             ),
           ],
         ),
       ),
     );
   }

  Widget _buildReportCard(Map<String, dynamic> record) {
     bool isFavorited = record['is_favourite'] ?? false;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppPallete.primaryColor.withOpacity(0.1),
          child: Icon(
            // Use isFavorited status for icon display priority
            // isFavorited ? Icons.favorite : _getIconForType(record['type']),
            _getIconForType(record['type']), // Keep type icon consistent
            color: isFavorited ? Colors.red : _getColorForType(record['type']),
          ),
        ),
        title: Text(record['title'] ?? 'Untitled'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${record['category'] ?? 'Unknown'}'),
            if (record['record_date'] != null)
              Text('Date: ${_formatDate(record['record_date'])}'),
            // Indicate if there's an attachment
             if (record['doc_link'] != null)
              const Text(
                'Attachment Available',
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Favorite Toggle Button
            IconButton(
               visualDensity: VisualDensity.compact,
               tooltip: isFavorited ? 'Remove from Favorites' : 'Add to Favorites',
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.red : Colors.grey,
              ),
              onPressed: () => _toggleFavorite(record['id']),
            ),
            // More Options Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'More Options',
              onSelected: (value) {
                if (value == 'delete') {
                  _confirmDelete(record['id']);
                } else if (value == 'details') {
                  _viewRecordDetails(record);
                } else if (value == 'edit') {
                  _editRecord(record);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'details',
                  child: ListTile(leading: Icon(Icons.info_outline), title: Text('View Details')),
                ),
                 const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit Record')),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(leading: Icon(Icons.delete_outline, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red))),
                ),
              ],
            ),
          ],
        ),
         onTap: () => _viewRecordDetails(record), // Allow tapping anywhere on the tile to view details
      ),
    );
  }

   Future<void> _confirmDelete(String recordId) async {
     if (_patientId == null) return; // Need patientId to delete securely
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

     if (confirmed == true) {
       try {
         // Pass patientId to backend delete method
         await _backend.deleteRecord(_patientId!, recordId);
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Record deleted successfully')),
           );
           _loadRecords(); // Refresh the list after deletion
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

  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'report':
        return Icons.description;
      case 'prescription':
        return Icons.medical_services;
      case 'note':
        return Icons.note;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getColorForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'report':
        return Colors.blue;
      case 'prescription':
        return Colors.green;
      case 'note':
        return Colors.orange;
      default:
        return Colors.black87;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal(); // Ensure local time display
      return DateFormat('MMM dd, yyyy').format(date); // Consistent format
    } catch (e) {
      return dateString; // Fallback
    }
  }

  Future<void> _toggleFavorite(String recordId) async {
    if (_patientId == null) return; // Check patientId
    try {
      // Pass patientId to backend toggle method
      await _backend.toggleFavorite(_patientId!, recordId);
      _loadRecords(); // Refresh list to show updated favorite status
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

   Future<void> _viewRecordDetails(Map<String, dynamic> record) async {
     final docLink = record['doc_link'] as String?;

     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text(record['title'] ?? 'Record Details'),
         content: SingleChildScrollView( // Make content scrollable
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min, // Fit content
             children: [
               _detailRow('Type:', record['type'] ?? 'Unknown'),
               _detailRow('Category:', record['category'] ?? 'Unknown'),
               _detailRow('Confidentiality:', record['level'] ?? 'medium'),
               _detailRow('Date:', _formatDate(record['record_date'] ?? 'Unknown')),
                if (record['description'] != null && record['description'].isNotEmpty)
                  _detailRow('Description:', record['description']),

               // Attachment Section
               if (docLink != null) ...[
                 const SizedBox(height: 16),
                 const Text('Attachment:', style: TextStyle(fontWeight: FontWeight.bold)),
                 const SizedBox(height: 8),
                 _buildAttachmentItem(docLink), // Use helper for attachment display
               ],
             ],
           ),
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context),
             child: const Text('Close'),
           ),
         ],
       ),
     );
   }

   // Helper widget for detail rows in the dialog
   Widget _detailRow(String label, String value) {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 4.0),
       child: RichText(
         text: TextSpan(
           style: DefaultTextStyle.of(context).style.copyWith(fontSize: 15), // Inherit text style
           children: [
             TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
             TextSpan(text: value),
           ],
         ),
       ),
     );
   }

   // Helper widget for displaying attachment in the details dialog
   Widget _buildAttachmentItem(String url) {
     // Attempt to get a readable file name from the URL
     final fileName = path.basename(url);
     return ListTile(
       contentPadding: EdgeInsets.zero,
       leading: Icon(_getAttachmentIcon(fileName)), // Use existing helper
       title: Text(
         fileName,
         overflow: TextOverflow.ellipsis,
         style: const TextStyle(fontSize: 14),
       ),
       trailing: IconButton(
         icon: const Icon(Icons.open_in_new, size: 20),
         tooltip: 'Open Attachment',
         onPressed: () => _openAttachment(url),
       ),
       onTap: () => _openAttachment(url), // Allow tapping list tile too
     );
   }


  // Helper function to get appropriate icon based on file extension
   IconData _getAttachmentIcon(String fileName) {
     final ext = path.extension(fileName).toLowerCase();
     if (ext == '.pdf') return Icons.picture_as_pdf;
     if (['.jpg', '.jpeg', '.png', '.gif', '.bmp'].contains(ext)) return Icons.image;
     if (['.doc', '.docx'].contains(ext)) return Icons.description; // Word docs
     // Add more types as needed
     return Icons.insert_drive_file; // Default
   }


   // Helper function to launch the attachment URL
   Future<void> _openAttachment(String url) async {
     final uri = Uri.tryParse(url);
     if (uri == null) {
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Invalid attachment URL')), );
        return;
     }
     // Use launchUrl which handles different URL types
     if (await canLaunchUrl(uri)) {
       // Try launching in external app, might work better for various file types
       await launchUrl(uri, mode: LaunchMode.externalApplication);
     } else {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Could not open attachment')),
         );
       }
     }
   }


  Future<void> _editRecord(Map<String, dynamic> record) async {
    if (_patientId == null) return; // Check patientId
     // Use GoRouter to navigate to the edit screen, passing the record data
    final result = await context.push<bool>(
       '/patient/health-record/edit',
       extra: record,
     );

     // If the edit screen returned true (indicating success), reload records
     if (result == true && mounted) {
       _loadRecords();
     }
  }


  Future<void> _navigateToAddReport() async {
    if (_patientId == null) return; // Check patientId
    // Use GoRouter to navigate to the add screen
    final result = await context.push<bool>('/patient/health-record/add');

    // If the add screen returned true (indicating success), reload records
    if (result == true && mounted) {
      _loadRecords();
    }
  }
}

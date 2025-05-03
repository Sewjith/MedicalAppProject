import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;
import '../../../core/common/cubits/user_session/app_user_cubit.dart';
import '../../../core/themes/color_palette.dart';
import 'H_Record_backend.dart';
import 'add_report.dart';

class HealthRecordScreen extends StatefulWidget {
  const HealthRecordScreen({super.key});

  @override
  State<HealthRecordScreen> createState() => _HealthRecordScreenState();
}

class _HealthRecordScreenState extends State<HealthRecordScreen> {
  final _backend = HealthRecordBackend();
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;
  bool _showFavorites = false;
  String? _currentCategory;
  String? _patientId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePatientIdAndLoadRecords();
  }

  void _initializePatientIdAndLoadRecords() {
     WidgetsBinding.instance.addPostFrameCallback((_) {
        final userState = context.read<AppUserCubit>().state;
        if (userState is AppUserLoggedIn && userState.user.role == 'patient') {
          _patientId = userState.user.uid;
          if (_patientId != null && _patientId!.isNotEmpty) {
            _loadRecords();
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
    if (_patientId == null || !mounted) {
       if (mounted) {
          setState(() {
             _isLoading = false;
             if (_patientId == null) {
                _errorMessage = _errorMessage ?? "Patient ID not available.";
             }
          });
       }
       return;
    }

    setState(() => _isLoading = true);
    _errorMessage = null;

    try {
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
            onPressed: _patientId == null ? null : () {
              setState(() => _showFavorites = !_showFavorites);
              _loadRecords();
            },
          ),
        ],
      ),
      body: _buildBody(),
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
     if (_patientId == null && !_isLoading) {
        return Center(
          child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Text(_errorMessage ?? "Patient ID not found. Cannot load records.", style: TextStyle(color: Colors.red)),
          ),
        );
     }
    return RefreshIndicator(
       onRefresh: _loadRecords,
       child: SingleChildScrollView(
         physics: const AlwaysScrollableScrollPhysics(),
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
              _loadRecords();
            },
          ),
        if (_currentCategory != null)
          Chip(
            label: Text('Category: $_currentCategory'),
            onDeleted: () {
              setState(() => _currentCategory = null);
              _loadRecords();
            },
          ),
        if (_showFavorites)
          Chip(
            avatar: const Icon(Icons.favorite, color: Colors.red, size: 16),
            label: const Text('Favorites'),
            onDeleted: () {
              setState(() => _showFavorites = false);
              _loadRecords();
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
      constraints: BoxConstraints(minHeight: containerHeight),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFCAD6FF).withOpacity(0.3),
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
                  shrinkWrap: true, // Important for Column layout
                  physics: const NeverScrollableScrollPhysics(), // Disable inner scrolling
                  itemCount: _records.length,
                  itemBuilder: (context, index) =>
                      _buildReportCard(_records[index]),
                ),
    );
  }

  Widget _buildCategoryGrid() {
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
        childAspectRatio: 1.4,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) =>
          _buildCategoryTile(categories[index], icons[index]),
    );
  }

  Widget _buildCategoryTile(String category, IconData icon) {
    bool isActive = _currentCategory == category;
    return InkWell(
      onTap: () {
        setState(() => _currentCategory = category);
        _loadRecords();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF003A9E) : const Color(0xFF2260FF),
          borderRadius: BorderRadius.circular(16),
           border: isActive ? Border.all(color: Colors.white, width: 2) : null,
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


  Widget _buildReportCard(Map<String, dynamic> record) {
    bool isFavorited = record['is_favourite'] ?? false;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppPallete.primaryColor.withOpacity(0.1),
          child: Icon(
            _getIconForType(record['type']),
            color: _getColorForType(record['type']),
          ),
        ),
        title: Text(record['title'] ?? 'Untitled'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${record['category'] ?? 'Unknown'}'),
            if (record['record_date'] != null)
              Text('Date: ${_formatDate(record['record_date'])}'),
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
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: isFavorited ? 'Remove from Favorites' : 'Add to Favorites',
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.red : Colors.grey,
              ),
              onPressed: () => _toggleFavorite(record['id']),
            ),
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
         onTap: () => _viewRecordDetails(record),
      ),
    );
  }

  Future<void> _confirmDelete(String recordId) async {
    if (_patientId == null) return;
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
        await _backend.deleteRecord(_patientId!, recordId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record deleted successfully')),
          );
          _loadRecords();
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
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _toggleFavorite(String recordId) async {
     if (_patientId == null) return;
    try {
      await _backend.toggleFavorite(_patientId!, recordId);
      _loadRecords();
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
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Type:', record['type'] ?? 'Unknown'),
              _detailRow('Category:', record['category'] ?? 'Unknown'),
              _detailRow('Confidentiality:', record['level'] ?? 'medium'),
              _detailRow('Date:', _formatDate(record['record_date'] ?? 'Unknown')),
              if (record['description'] != null && record['description'].isNotEmpty)
                 _detailRow('Description:', record['description']),

              if (docLink != null) ...[
                const SizedBox(height: 16),
                const Text('Attachment:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildAttachmentItem(docLink),
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

   Widget _detailRow(String label, String value) {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 4.0),
       child: RichText(
         text: TextSpan(
           style: DefaultTextStyle.of(context).style.copyWith(fontSize: 15),
           children: [
             TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
             TextSpan(text: value),
           ],
         ),
       ),
     );
   }

  Widget _buildAttachmentItem(String url) {
    final fileName = path.basename(url);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(_getAttachmentIcon(fileName)),
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
       onTap: () => _openAttachment(url),
    );
  }

  IconData _getAttachmentIcon(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    if (ext == '.pdf') return Icons.picture_as_pdf;
    if (['.jpg', '.jpeg', '.png', '.gif', '.bmp'].contains(ext)) return Icons.image;
    if (['.doc', '.docx'].contains(ext)) return Icons.description;
    return Icons.insert_drive_file;
  }

  Future<void> _openAttachment(String url) async {
     final uri = Uri.tryParse(url);
     if (uri == null) {
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Invalid attachment URL')), );
        return;
     }
    if (await canLaunchUrl(uri)) {
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
     if (_patientId == null) return;
    final result = await context.push<bool>(
      '/patient/health-record/edit',
      extra: record, // Pass the record data
    );

    if (result == true && mounted) {
      _loadRecords();
    }
  }

  Future<void> _navigateToAddReport() async {
     if (_patientId == null) return;
    final result = await context.push<bool>('/patient/health-record/add');

    if (result == true && mounted) {
      _loadRecords();
    }
  }
}
import 'package:flutter/material.dart';
import 'H_Record_backend.dart';
import 'add_report.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      _records = await _backend.getHealthRecords(
        favoritesOnly: _showFavorites,
        category: _currentCategory,
      );
    } catch (e) {
      debugPrint('Load records error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading records: ${e.toString()}')),
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
        actions: [
          IconButton(
            icon: Icon(_showFavorites ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() => _showFavorites = !_showFavorites);
              _loadRecords();
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddReport,
        backgroundColor: const Color(0xFF2260FF),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterChips(),
          const SizedBox(height: 16),
          const Text('Recently Added Reports:',
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
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      children: [
        if (_currentCategory != null || _showFavorites)
          ActionChip(
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
            label: const Text('Favorites Only'),
            onDeleted: () {
              setState(() => _showFavorites = false);
              _loadRecords();
            },
          ),
      ],
    );
  }

  Widget _buildReportsContainer() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFCAD6FF).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(10),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(child: Text('No records found'))
              : ListView.builder(
                  itemCount: _records.length,
                  itemBuilder: (context, index) =>
                      _buildReportCard(_records[index]),
                ),
    );
  }

  Widget _buildCategoryGrid() {
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
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == categories.length) {
          return _buildAddReportTile();
        }
        return _buildCategoryTile(categories[index], icons[index]);
      },
    );
  }

  Widget _buildCategoryTile(String category, IconData icon) {
    return InkWell(
      onTap: () {
        setState(() => _currentCategory = category);
        _loadRecords();
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2260FF),
          borderRadius: BorderRadius.circular(16),
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

  Widget _buildAddReportTile() {
    return InkWell(
      onTap: _navigateToAddReport,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2260FF).withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFCAD6FF).withOpacity(0.3),
          child: Icon(
            record['is_favourite']
                ? Icons.favorite
                : _getIconForType(record['type']),
            color: record['is_favourite']
                ? Colors.red
                : _getColorForType(record['type']),
          ),
        ),
        title: Text(record['title'] ?? 'Untitled'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${record['category'] ?? 'Unknown'}'),
            if (record['record_date'] != null)
              Text('Date: ${_formatDate(record['record_date'])}'),
            if (record['record_id'] != null) Text('ID: ${record['record_id']}'),
            if (record['doc_link'] != null)
              const Text(
                'Has Attachment',
                style: TextStyle(color: Colors.blue),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(record['is_favourite']
                  ? Icons.favorite
                  : Icons.favorite_border),
              onPressed: () => _toggleFavorite(record['id']),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
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
                  child: Text('View Details'),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Record'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Record',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String recordId) async {
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
        await _backend.deleteRecord(recordId);
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
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _toggleFavorite(String recordId) async {
    try {
      await _backend.toggleFavorite(recordId);
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
            children: [
              Text('Type: ${record['type'] ?? 'Unknown'}'),
              const SizedBox(height: 8),
              Text('Category: ${record['category'] ?? 'Unknown'}'),
              const SizedBox(height: 8),
              Text('Confidentiality: ${record['level'] ?? 'medium'}'),
              if (record['description'] != null) ...[
                const SizedBox(height: 8),
                Text('Description: ${record['description']}'),
              ],
              const SizedBox(height: 8),
              Text('Date: ${_formatDate(record['record_date'] ?? 'Unknown')}'),
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

  Widget _buildAttachmentItem(String url) {
    final fileName = Uri.parse(url).pathSegments.last;
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
        onPressed: () => _openAttachment(url),
      ),
    );
  }

  IconData _getAttachmentIcon(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    if (ext == 'pdf') return Icons.picture_as_pdf;
    if (ext == 'jpg' || ext == 'jpeg' || ext == 'png') return Icons.image;
    if (ext == 'doc' || ext == 'docx') return Icons.description;
    return Icons.insert_drive_file;
  }

  Future<void> _openAttachment(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open attachment')),
        );
      }
    }
  }

  Future<void> _editRecord(Map<String, dynamic> record) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddReportScreen(existingRecord: record),
      ),
    );

    if (result == true && mounted) {
      _loadRecords();
    }
  }

  Future<void> _navigateToAddReport() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddReportScreen()),
    );

    if (result == true && mounted) {
      _loadRecords();
    }
  }
}

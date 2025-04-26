import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      _records = await _backend.getHealthRecords(favoritesOnly: _showFavorites);
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
          const Text('Recently Added Reports:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildReportsContainer(),
          const SizedBox(height: 20),
          const Text('Select a category:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildCategoryGrid(),
        ],
      ),
    );
  }

  Widget _buildReportsContainer() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFCAD6FF),
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
      'Add Report'
    ];

    const icons = [
      Icons.history,
      Icons.calendar_today,
      Icons.note,
      Icons.local_hospital,
      Icons.emergency,
      Icons.visibility,
      Icons.upload_file,
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) =>
          _buildCategoryTile(categories[index], icons[index], index == 6),
    );
  }

  Widget _buildCategoryTile(String category, IconData icon, bool isAdd) {
    return InkWell(
      onTap: () => isAdd ? _navigateToAddReport() : _filterByCategory(category),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 46, 163),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            Text(category, style: const TextStyle(color: Colors.white)),
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
          backgroundColor: const Color(0xFFCAD6FF),
          child: Icon(
            record['is_favorite']
                ? Icons.favorite
                : _getIconForType(record['type']),
            color: record['is_favorite']
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
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(record['is_favorite']
                  ? Icons.favorite
                  : Icons.favorite_border),
              onPressed: () => _toggleFavorite(record['id']),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _viewRecordDetails(record),
            ),
          ],
        ),
      ),
    );
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
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _filterByCategory(String category) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      _records = await _backend.getHealthRecords(
        favoritesOnly: _showFavorites,
        category: category,
      );
    } catch (e) {
      debugPrint('Filter error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error filtering: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

  Future<void> _navigateToAddReport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddReportScreen()),
    );
    _loadRecords();
  }
}

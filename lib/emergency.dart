import 'package:flutter/material.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Emergency Health Data',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2260FF),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilterOptions(),
          Expanded(child: _buildReportList(context)),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFCAD6FF),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DropdownButton<String>(
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              items: <String>['All', 'Recent', 'Favorites'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
              hint: const Text('Filter by'),
            ),
            ElevatedButton(
              onPressed: () {
                // Refresh logic can go here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2260FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList(BuildContext context) {
    // Example list of emergency reports, you can fetch it dynamically
    List<Map<String, String>> reports = List.generate(20, (index) {
      return {
        'title': 'Emergency Contact - John Doe $index',
        'subtitle': 'Category: Health Emergency\nAdded: Feb 9, 2024',
      };
    });

    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            color: const Color(0xFFCAD6FF),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: const Icon(Icons.local_hospital,
                    size: 35, color: Colors.black54),
              ),
              title: Text(
                reports[index]['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(reports[index]['subtitle']!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.red),
                    onPressed: () {
                      // Handle like button press
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black54),
                    onPressed: () {
                      _showDeleteConfirmation(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline,
                        color: Colors.blueAccent),
                    onPressed: () {
                      _showDownloadOrViewOptions(context, reports[index]);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Do you want to delete this record?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle delete logic here
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2260FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showDownloadOrViewOptions(
      BuildContext context, Map<String, String> report) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose an Option'),
          content: Text(
              'Do you want to download or view the emergency contact: "${report['title']}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _viewReport(context, report); // Show the report details
              },
              child: const Text('View'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadReport(report); // Simulate the download
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2260FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Download'),
            ),
          ],
        );
      },
    );
  }

  void _viewReport(BuildContext context, Map<String, String> report) {
    // Navigate to a page where we display the report
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportDetailPage(report: report),
      ),
    );
  }

  void _downloadReport(Map<String, String> report) {
    // Logic to simulate downloading the report (e.g., print the name)
    print(
        "Downloading ${report['title']}..."); // Replace with actual download logic
  }
}

class ReportDetailPage extends StatelessWidget {
  final Map<String, String> report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Detail'),
        backgroundColor: const Color(0xFF2260FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${report['title']}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
                'Description: This is the detail view for the report titled "${report['title']}".'),
            SizedBox(height: 8),
            Text('Category: Health Emergency'),
            SizedBox(height: 8),
            Text('Added Date: Feb 9, 2024'),
            SizedBox(height: 8),
            Text('Last Modified Date: Feb 9, 2024'),
          ],
        ),
      ),
    );
  }
}

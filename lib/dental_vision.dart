import 'package:flutter/material.dart';

class DentalVisionPage extends StatelessWidget {
  const DentalVisionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dental & Vision Reports'),
        backgroundColor: const Color(0xFF2260FF),
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
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          DropdownButton<String>(
            items: <String>['All', 'Recent', 'Favorites'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (_) {}, // Add filter logic here
            hint: const Text('Filter by'),
          ),
          ElevatedButton(
            onPressed: () {
              // Refresh logic can go here
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(BuildContext context) {
    return ListView.builder(
      itemCount: 20, // Adjust this as needed for your data
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.local_hospital, size: 30),
              ),
              title: const Text('Vision Exam - Dr. Smith'),
              subtitle: const Text('Category: Vision\nAdded: Feb 5, 2024'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      // Handle like button press
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteConfirmation(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      _showReportDetails(context);
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
          content: const Text('Do you want to delete this report?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                // Handle delete logic here
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showReportDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Title: Vision Exam - Dr. Smith'),
              Text(
                  'Description: This report includes the results of your vision exam.'),
              Text('Added Date: Feb 5, 2024'),
              Text('Last Modified Date: Feb 6, 2024'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

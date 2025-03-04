import 'package:flutter/material.dart';

class VaccinationsPage extends StatelessWidget {
  const VaccinationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Vaccination Records',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2260FF),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilterOptions(),
          Expanded(child: _buildVaccinationList(context)),
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
              onChanged: (_) {}, // Add filter logic here
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

  Widget _buildVaccinationList(BuildContext context) {
    List<Map<String, String>> vaccinations = List.generate(20, (index) {
      return {
        'title': 'Flu Vaccine $index',
        'subtitle': 'Category: Immunization\nAdded: Jan 30, 2024',
      };
    });

    return ListView.builder(
      itemCount: vaccinations.length,
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
                child: const Icon(Icons.medication,
                    size: 35, color: Colors.black54),
              ),
              title: Text(
                vaccinations[index]['title']!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(vaccinations[index]['subtitle']!),
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
                      _showDownloadOrViewOptions(context, vaccinations[index]);
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
          content: const Text('Do you want to delete this vaccination record?'),
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
      BuildContext context, Map<String, String> vaccination) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose an Option'),
          content: Text(
              'Do you want to download or view the vaccination record: "${vaccination['title']}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _viewVaccinationRecord(
                    context, vaccination); // Show the vaccination details
              },
              child: const Text('View'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadVaccinationRecord(
                    vaccination); // Simulate the download
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

  void _viewVaccinationRecord(
      BuildContext context, Map<String, String> vaccination) {
    // Navigate to a page where we display the vaccination details
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VaccinationDetailPage(vaccination: vaccination),
      ),
    );
  }

  void _downloadVaccinationRecord(Map<String, String> vaccination) {
    // Logic to simulate downloading the vaccination record (e.g., print the name)
    print(
        "Downloading ${vaccination['title']}..."); // Replace with actual download logic
  }
}

class VaccinationDetailPage extends StatelessWidget {
  final Map<String, String> vaccination;

  const VaccinationDetailPage({super.key, required this.vaccination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccination Detail'),
        backgroundColor: const Color(0xFF2260FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${vaccination['title']}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
                'Description: This is the detail view for the vaccination titled "${vaccination['title']}".'),
            SizedBox(height: 8),
            Text('Category: Immunization'),
            SizedBox(height: 8),
            Text('Added Date: Jan 30, 2024'),
            SizedBox(height: 8),
            Text('Last Modified Date: Feb 1, 2024'),
          ],
        ),
      ),
    );
  }
}

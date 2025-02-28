import 'package:flutter/material.dart';

class ViewReportsPage extends StatelessWidget {
  const ViewReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Reports'),
        backgroundColor: Color(0xFF2260FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter options
            Row(
              children: [
                IconButton(icon: Icon(Icons.sort_by_alpha), onPressed: () {}),
                IconButton(icon: Icon(Icons.date_range), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 20),
            // List of reports
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    color: Color(0xFFCAD6FF),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.picture_as_pdf),
                      ),
                      title: Text('Blood Test Report - Jan 2024'),
                      subtitle: Text('Issued by XYZ Hospital'),
                      trailing:
                          IconButton(icon: Icon(Icons.info), onPressed: () {}),
                    ),
                  );
                },
              ),
            ),
            // View More Button
            ElevatedButton(
              onPressed: () {},
              style:
                  ElevatedButton.styleFrom(backgroundColor: Color(0xFF2260FF)),
              child: const Text('View More'),
            ),
          ],
        ),
      ),
    );
  }
}

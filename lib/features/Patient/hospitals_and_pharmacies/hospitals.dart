import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HospitalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospitals'),
      ),
      body: ListView(
        children: [
          HospitalCard(
            name: 'National Hospital of Sri Lanka',
            address: 'Regent St, Colombo',
            contact: '011 2691111',
            location: 'Colombo',
            onMapTap: () {
              // TODO: Implement Google Maps integration
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Map integration not implemented yet')),
              );
            },
          ),
          HospitalCard(
            name: 'Asiri Surgical Hospital',
            address: 'Kirula Road, Colombo 05',
            contact: '011 4523300',
            location: 'Colombo 05',
            onMapTap: () {
              // TODO: Implement Google Maps integration
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Map integration not implemented yet')),
              );
            },
          ),
          HospitalCard(
            name: 'Lanka Hospitals',
            address: 'Kirula Road, Colombo 05',
            contact: '011 5430000',
            location: 'Colombo',
            onMapTap: () {
              // TODO: Implement Google Maps integration
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Map integration not implemented yet')),
              );
            },
          ),
          HospitalCard(
            name: 'Hemas Hospital Wattala',
            address: 'Negombo Road, Wattala',
            contact: '011 7888888',
            location: 'Wattala',
            onMapTap: () {
              // TODO: Implement Google Maps integration
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Map integration not implemented yet')),
              );
            },
          ),
          HospitalCard(
            name: 'Nawaloka Hospital',
            address: 'Negombo Rd, Peliyagoda',
            contact: '011 5777777',
            location: 'Peliyagoda',
            onMapTap: () {
              // TODO: Implement Google Maps integration
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Map integration not implemented yet')),
              );
            },
          ),
          // Add more HospitalCard widgets as needed
        ],
      ),
    );
  }
}

class HospitalCard extends StatelessWidget {
  final String name;
  final String address;
  final String contact;
  final String location;
  final VoidCallback onMapTap;

  const HospitalCard({
    Key? key,
    required this.name,
    required this.address,
    required this.contact,
    required this.location,
    required this.onMapTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Address: $address'),
            const SizedBox(height: 4),
            Text('Contact: $contact'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onMapTap,
                  icon: const Icon(Icons.location_on),
                  label: Text('Show on Map ($location)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

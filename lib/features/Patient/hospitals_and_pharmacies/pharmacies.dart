import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PharmacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacies'),
      ),
      body: ListView(
        children: [
          PharmacyCard(
            name: 'Union Chemists',
            address: 'Main Street, Colombo',
            contact: '011 2548796',
            location: 'Colombo',
            onMapTap: () {
              // TODO: Implement Google Maps integration
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Map integration not implemented yet')),
              );
            },
          ),
          PharmacyCard(
            name: 'Wellcare Pharmacy',
            address: 'Galle Road, Bambalapitiya',
            contact: '011 2589632',
            location: 'Bambalapitiya',
            onMapTap: () {
              // TODO: Implement Google Maps integration
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Map integration not implemented yet')),
              );
            },
          ),
          PharmacyCard(
            name: 'Osusala',
            address: 'Kandy Road, Kiribathgoda',
            contact: '011 2956321',
            location: 'Kiribathgoda',
            onMapTap: () {
              // TODO: Implement Google Maps integration
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Map integration not implemented yet')),
              );
            },
          ),
          // Add more PharmacyCard widgets as needed
        ],
      ),
    );
  }
}

class PharmacyCard extends StatelessWidget {
  final String name;
  final String address;
  final String contact;
  final String location;
  final VoidCallback onMapTap;

  const PharmacyCard({
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

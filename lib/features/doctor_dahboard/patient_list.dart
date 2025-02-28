 import 'package:flutter/material.dart';
 import 'package:medical_app/core/themes/color_palette.dart';

 void main() {
   runApp(MyApp());
 }

 class MyApp extends StatelessWidget {
   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       debugShowCheckedModeBanner: false,
       home: PatientListPage(),
     );
   }
 }

 class PatientListPage extends StatefulWidget {
   @override
   _PatientListPageState createState() => _PatientListPageState();
 }

 class _PatientListPageState extends State<PatientListPage> {
   List<Map<String, String>> patients = [
     {'name': 'John Smith', 'gender': 'Male', 'age': '45', 'image': 'assets/images/pa1.jpg'},
     {'name': 'Hilda Hunter', 'gender': 'Female', 'age': '36', 'image': 'assets/images/pa2.jpg'},
     {'name': 'Michel Bomb', 'gender': 'Male', 'age': '28', 'image': 'assets/images/pa3.jpg'},
     {'name': 'Ellen Barton', 'gender': 'Female', 'age': '39', 'image': 'assets/images/pa4.jpg'},
     {'name': 'Thad Ennigs', 'gender': 'Male', 'age': '55', 'image': 'assets/images/pa5.jpg'},
     {'name': 'Brittni Lando', 'gender': 'Female', 'age': '32', 'image': 'assets/images/pa6.webp'},
   ];

   List<Map<String, String>> removedPatients = [];
   Map<String, List<String>> patientFiles = {
     'John Smith': ['Prescription.pdf', 'X-ray report.pdf'],
     'Hilda Hunter': ['Checkup.pdf'],
     'Michel Bomb': ['Prescription.pdf'],
     'Ellen Barton': ['X-ray report.pdf', 'Prescription.pdf'],
     'Thad Ennigs': ['Checkup.pdf'],
     'Brittni Lando': ['Prescription.pdf', 'X-ray report.pdf'],
   };

   TextEditingController _searchController = TextEditingController();
   List<Map<String, String>> filteredPatients = [];

   int _selectedIndex = 0;

   @override
   void initState() {
     super.initState();
     filteredPatients = List.from(patients);
     _searchController.addListener(_filterPatients);
   }

   void _filterPatients() {
     setState(() {
       filteredPatients = patients
           .where((patient) =>
           patient['name']!.toLowerCase().contains(_searchController.text.toLowerCase()))
           .toList();
     });
   }

   void _removePatient(int index) {
     setState(() {
       removedPatients.add(filteredPatients[index]);
       patients.removeAt(index);
       filteredPatients.removeAt(index);
     });
   }

   void _restorePatients() {
     setState(() {
       patients.addAll(removedPatients);
       filteredPatients = List.from(patients);
       removedPatients.clear();
     });
   }

   void _downloadFile(String fileName) {
     // Simulate a download by showing a message
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Downloading $fileName...')),
     );
   }


   void _onItemTapped(int index) {
     setState(() {
       _selectedIndex = index;
     });
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: AppPallete.secondaryColor,
       appBar: AppBar(
         backgroundColor: AppPallete.secondaryColor,
         elevation: 0,
         leading: IconButton(
           icon: const Icon(Icons.arrow_back_ios, color: AppPallete.primaryColor),
           onPressed: () {
             Navigator.pop(context);
           },
         ),
         title: Center(
           child: Text(
             'Patient List & Reports',
             style: TextStyle(
               color: AppPallete.primaryColor,
               fontWeight: FontWeight.bold,
             ),
           ),
         ),
         actions: [
           IconButton(
             icon: Icon(Icons.restore, color: AppPallete.primaryColor),
             onPressed: _restorePatients,
           ),
         ],
       ),
       body: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             TextField(
               controller: _searchController,
               decoration: InputDecoration(
                 hintText: 'Search...',
                 hintStyle: TextStyle(color: AppPallete.textColor),
                 prefixIcon: Icon(Icons.search, color: AppPallete.textColor),
                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(10),
                   borderSide: BorderSide(color: AppPallete.darkText),
                 ),
               ),
             ),
             const SizedBox(height: 16),
             Expanded(
               flex: 2,
               child: ListView.builder(
                 itemCount: filteredPatients.length,
                 itemBuilder: (context, index) {
                   return ListTile(
                     leading: CircleAvatar(
                       backgroundImage: AssetImage(filteredPatients[index]['image']!),
                     ),
                     title: Text(
                       filteredPatients[index]['name']!,
                       style: TextStyle(color: AppPallete.textColor),
                     ),
                     subtitle: Text(
                       "${filteredPatients[index]['gender']}, ${filteredPatients[index]['age']}",
                       style: TextStyle(color: AppPallete.greyColor),
                     ),
                     onTap: () {
                       _showPatientFiles(filteredPatients[index]['name']!);
                     },
                     trailing: PopupMenuButton<String>(
                       onSelected: (value) {
                         if (value == 'Remove') {
                           _removePatient(index);
                         }
                       },
                       itemBuilder: (context) => [
                         PopupMenuItem(
                           value: 'Remove',
                           child: Text('Remove', style: TextStyle(color: AppPallete.textColor)),
                         ),
                       ],
                     ),
                   );
                 },
               ),
             ),
           ],
         ),
       ),
       bottomNavigationBar: BottomNavBar(
         selectedIndex: _selectedIndex,
         onItemTapped: _onItemTapped,
       ),
     );
   }


   void _showPatientFiles(String patientName) {
     showDialog(
       context: context,
       builder: (context) {
         return AlertDialog(
           title: Text('$patientName Files', style: TextStyle(color: AppPallete.textColor)),
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               for (String file in patientFiles[patientName]!)
                 ListTile(
                   title: Text(file, style: TextStyle(color: AppPallete.textColor)),
                   trailing: IconButton(
                     icon: Icon(Icons.download, color: AppPallete.primaryColor),
                     onPressed: () => _downloadFile(file),
                   ),
                 ),
             ],
           ),
           actions: [
             TextButton(
               onPressed: () {
                 Navigator.of(context).pop();
               },
               child: Text('Close', style: TextStyle(color: AppPallete.primaryColor)),
             ),
           ],
         );
       },
     );
   }
 }

 class BottomNavBar extends StatelessWidget {
   final int selectedIndex;
   final Function(int) onItemTapped;

   BottomNavBar({required this.selectedIndex, required this.onItemTapped});

   @override
   Widget build(BuildContext context) {
     return BottomNavigationBar(
       currentIndex: selectedIndex, // Track the selected index
       onTap: onItemTapped, // Handle item tap
       selectedItemColor: AppPallete.primaryColor, // Selected item color
       unselectedItemColor: AppPallete.greyColor, // Unselected item color
       type: BottomNavigationBarType.fixed, // Fixed Bottom Navigation Bar
       items: [
         BottomNavigationBarItem(
           icon: Icon(Icons.home),
           label: "", // Empty label
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.chat),
           label: "", // Empty label
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.person),
           label: "", // Empty label
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.calendar_today),
           label: "", // Empty label
         ),
       ],
     );
   }
 }

import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/core/bottom_nav_bar.dart';
import 'package:medical_app/features/patient_dashboard/dashboard.dart';
import 'package:medical_app/features/patient_dashboard/pages/a-z.dart';
import 'package:medical_app/features/patient_dashboard/pages/female_doctors.dart';
import 'package:medical_app/features/patient_dashboard/pages/male_doctors.dart';

void main() {
  runApp(Favorite());
}

class Favorite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FavoriteScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });

    switch(index){
      case 0:
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Dashboard()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Placeholder()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Placeholder()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Placeholder()),
        );
        break;

    }
  }

  TabController? _tabController;
  String _activeSort = 'Favorites';
  List<Map<String, String>> _doctors = [
    {'name': 'Dr. Olivia Turner, M.D.', 'specialty': 'Dermato-Endocrinology', 'image': 'assets/images/doctor.jpg', },
    {'name': 'Dr. Alexander Bennett, Ph.D.', 'specialty': 'Dermato-Genetics', 'image': 'assets/images/doctor.jpg'},
    {'name': 'Dr. Sophia Martinez, Ph.D.', 'specialty': 'Cosmetic Bioengineering', 'image': 'assets/images/doctor.jpg'},
    {'name': 'Dr. Michael Davidson, M.D.', 'specialty': 'Solar Dermatology', 'image': 'assets/images/doctor.jpg'},
  ];
  List<Map<String, String>> _filteredDoctors = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredDoctors = _doctors;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSortSelection(String selectedSort) {
    setState(() {
      _activeSort = selectedSort;
    });
  }
  void _filterDoctors(String query) {
    List<Map<String, String>> filteredList = _doctors.where((doctor) {
      final nameLower = doctor['name']!.toLowerCase();
      final specialtyLower = doctor['specialty']!.toLowerCase();
      final queryLower = query.toLowerCase();

      return nameLower.contains(queryLower) || specialtyLower.contains(queryLower);
    }).toList();

    setState(() {
      _filteredDoctors = filteredList;
    });
  }


  Widget _buildDoctorCard(String name, String specialty, String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: Colors.blue[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    child: Row(
                      children: [
                        Icon(Icons.verified, color: AppPallete.headings, size: 20),
                        SizedBox(width: 5),
                        Text(
                          'Professional Doctor',
                          style: TextStyle(color: AppPallete.headings, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(imagePath),
                ),
                title: Text(
                  name,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppPallete.textColor),
                ),
                subtitle: Text(specialty),
                trailing: Icon(Icons.favorite, color: AppPallete.primaryColor),
              ),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    backgroundColor: AppPallete.headings,
                  ),
                  child: Text('Make Appointment', style: TextStyle(color: AppPallete.secondaryColor, fontSize: 19)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSortButton(String label, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () {
        _handleSortSelection(label);
      },
      child: Column(
        children: [
          Icon(
            icon,
            color: isActive ? AppPallete.primaryColor : AppPallete.greyColor,
            size: 26,
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppPallete.primaryColor : AppPallete.greyColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppPallete.transparentColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_sharp, color: AppPallete.primaryColor),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Dashboard()));
          },
        ),
        title: Text(
          'Favorite',
          style: TextStyle(fontSize: 35, color: AppPallete.primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.search, color: AppPallete.primaryColor), onPressed: () {
            showSearch(context: context, delegate: DoctorSearch(_doctors));
          }),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 5,),
                Text('Sort By:',
                  style: TextStyle(fontSize: 20, color: Colors.black45),),
                SizedBox(width: 4,),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Sort()));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _activeSort == 'A-Z' ? AppPallete.primaryColor : Colors.blue.shade100),
                  child: Text('A-Z', style: TextStyle(color: AppPallete.whiteColor)),
                ),
                SizedBox(width: 4,),
                Container(
                  decoration: BoxDecoration(
                    color: _activeSort == 'Favorites' ? AppPallete.primaryColor : Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => _handleSortSelection('Favorites'),
                    icon: Icon(Icons.favorite_border_outlined, color: AppPallete.whiteColor),
                  ),
                ),
                SizedBox(width: 4,),
                Container(
                  decoration: BoxDecoration(
                    color: _activeSort == 'Male' ? AppPallete.primaryColor : Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MaleDoctor()));
                    },
                    icon: Icon(Icons.male_outlined, color: AppPallete.whiteColor),
                  ),
                ),
                SizedBox(width: 4,),
                Container(
                  decoration: BoxDecoration(
                    color: _activeSort == 'Female' ? AppPallete.primaryColor : Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => FemaleDoctor()));
                    },
                    icon: Icon(Icons.female_outlined, color: AppPallete.whiteColor),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView.builder(
                  itemCount: _filteredDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _filteredDoctors[index];
                    return _buildDoctorCard(doctor['name']!, doctor['specialty']!, doctor['image']!);
                  },
                )
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
class DoctorSearch extends SearchDelegate {
  final List<Map<String, String>> doctors;

  DoctorSearch(this.doctors);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: AppPallete.primaryColor,),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new_sharp, color: AppPallete.primaryColor,),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Map<String, String>> searchResults = doctors.where((doctor) {
      return doctor['name']!.toLowerCase().contains(query.toLowerCase()) ||
          doctor['specialty']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchResults[index]['name']!),
          subtitle: Text(searchResults[index]['specialty']!),
          leading: CircleAvatar(
            backgroundImage: AssetImage(searchResults[index]['image']!),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Map<String, String>> searchResults = doctors.where((doctor) {
      return doctor['name']!.toLowerCase().contains(query.toLowerCase()) ||
          doctor['specialty']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchResults[index]['name']!),
          subtitle: Text(searchResults[index]['specialty']!),
          leading: CircleAvatar(
            backgroundImage: AssetImage(searchResults[index]['image']!),
          ),
        );
      },
    );
  }
}


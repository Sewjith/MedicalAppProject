import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/core/bottom_nav_bar.dart';
import 'package:medical_app/features/patient_dashboard/menu_nav.dart';
import 'package:medical_app/features/patient_dashboard/pages/favorite.dart';

void main(){
  runApp(Dashboard());
}
class Dashboard extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.light),

      debugShowCheckedModeBanner: false,
      home:DashboardScreen(),
    );
  }
}
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen> {
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

  @override
  Widget build(BuildContext context){
    return Scaffold(
      drawer: Drawer(
        child: SideMenu(),
      ),
      backgroundColor: AppPallete.whiteColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Builder(
                      builder: (context) => IconButton(
                        icon: Icon(Icons.menu, color: AppPallete.textColor),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    Row(
                      children:[
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: AssetImage('assets/images/patient.jpeg'),
                        ),
                        SizedBox(width: 7),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, Welcome Back',
                              style: TextStyle(
                                  fontSize: 17, color: AppPallete.headings
                              ),
                            ),
                            Text(
                              'Mrs. Anne',
                              style: TextStyle(
                                  fontSize: 20, color: AppPallete.textColor
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications_outlined, color: AppPallete.textColor),
                      onPressed: (){
                      },
                    ),
                  ],
                ),
              ),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  children: [
                    Column(
                      children: [
                        IconButton(onPressed: (){
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Favorite()));

                        }, icon: Icon(Icons.favorite_border_outlined, color: AppPallete.primaryColor, size: 30),),
                        Text(
                          'Favorite',
                          style: TextStyle(fontSize: 14, color: AppPallete.headings),
                        ),
                      ],
                    ),
                    SizedBox(width: 10),
                    Expanded(child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search_outlined),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(padding:
              const EdgeInsets.symmetric(horizontal:20 ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTabIcon(context, Icons.medical_services_outlined, 'Doctor', ''),
                    _buildTabIcon(context, Icons.local_pharmacy_rounded, 'Pharmacy', ''),
                    _buildTabIcon(context, Icons.local_hospital_rounded, 'Hospital', ''),
                    _buildTabIcon(context, Icons.local_hospital_outlined, 'Ambulance', '')
                  ],
                ),),
              SizedBox(height: 20),
              Padding(padding:
              const EdgeInsets.symmetric(horizontal:20 ),
                child: Row(
                  children: [
                    Text(
                      'Upcoming Schedule',
                      style: TextStyle(
                        fontSize: 24,
                        color: AppPallete.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppPallete.headings,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: AppPallete.greyColor,
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 10),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 44,
                                  backgroundImage: AssetImage('assets/images/doctor.jpg'),
                                ),
                                SizedBox(width: 7),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dr. John Smith, Ph.D',
                                      style: TextStyle(
                                        fontSize: 21, color: AppPallete.whiteColor, fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Cosmetic Bioengineering',
                                      style: TextStyle(
                                          fontSize: 19, color: AppPallete.whiteColor
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Monday, June 20 . 08.30 am',
                                      style: TextStyle(
                                          fontSize: 17, color: AppPallete.whiteColor
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Starts in 20 min',
                                  style: TextStyle(color: AppPallete.whiteColor, fontSize: 17),
                                ),
                                SizedBox(width: 100),
                                GestureDetector(
                                  onTap: (){
                                  },
                                  child: Container(
                                    width: 123,
                                    decoration: BoxDecoration(
                                      color: AppPallete.whiteColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.video_call_rounded, color: AppPallete.primaryColor),
                                          onPressed: () {
                                          },
                                        ),
                                        Text(
                                          'Join Call',
                                          style: TextStyle(
                                              fontSize: 18, fontWeight: FontWeight.bold, color: AppPallete.primaryColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              Padding(padding:
              const EdgeInsets.symmetric(horizontal:20 ),
                child: Row(
                  children: [
                    Text(
                      'On Demand',
                      style: TextStyle(
                        fontSize: 24,
                        color: AppPallete.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildOnDemandDoctorCard(
                      context,
                      'Dr. John Smith Ph.D.',
                      'Cosmetic Bioengineering',
                      150,
                      'assets/images/doctor.jpg',
                    ),
                  ],
                ),),
              SizedBox(height: 10),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildOnDemandDoctorCard(
                      context,
                      'Dr. John Smith Ph.D.',
                      'Cosmetic Bioengineering',
                      150,
                      'assets/images/doctor.jpg',
                    ),
                  ],
                ),),
              SizedBox(height: 10),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildOnDemandDoctorCard(
                      context,
                      'Dr. John Smith Ph.D.',
                      'Cosmetic Bioengineering',
                      150,
                      'assets/images/doctor.jpg',
                    ),
                  ],
                ),),
              SizedBox(height: 10),

            ],

          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
Widget _buildTabIcon(BuildContext context, IconData icon, String label, String destination) {
  return Column(
    children: [
      ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, destination);
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(16),
          backgroundColor: Colors.grey.shade200,
          elevation: 3,
        ),
        child: Icon(
          icon,
          color: AppPallete.headings,
          size: 30,
        ),
      ),
      SizedBox(height: 6),
      Text(
        label,
        style: TextStyle(fontSize: 14, color: AppPallete.headings),
      ),
    ],
  );
}

Widget _buildOnDemandDoctorCard(BuildContext context, String name, String speciality, int reviews, String imagePath){
  return Container(
    padding: EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppPallete.secondaryColor,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(color: AppPallete.greyColor,
          blurRadius: 1,
          offset: Offset(1, 1),),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: AssetImage(imagePath),
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppPallete.primaryColor),
            ),
            Text(
              speciality,
              style: TextStyle(fontSize: 14, color: AppPallete.greyColor),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.message_outlined, color: AppPallete.primaryColor, size: 18),
                Text("$reviews reviews",
                  style: TextStyle(fontSize: 16, color: AppPallete.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        Spacer(),
        IconButton(onPressed: () {}, icon: Icon(Icons.favorite_border_outlined, color: AppPallete.primaryColor),
        ),
      ],
    ),
  );
}
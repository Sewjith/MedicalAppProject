import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart'; // Import Cubit

import 'package:medical_app/core/themes/color_palette.dart';
import 'OveviewDB.dart'; // Ensure this uses the updated DB logic

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key); // Add Key

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {

  final OverviewDB _db = OverviewDB();
  String? _currentDoctorId; // Store dynamic doctor ID

  // State variables
  int newAppointments = 0;
  int totalPatients = 0;
  double totalEarnings = 0.0;
  List<double> registrationsData = List.filled(7, 0.0); // Initialize with defaults
  List<double> bookingsData = List.filled(7, 0.0); // Initialize with defaults
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDoctorAndFetchData();
    });
  }

  void _initializeDoctorAndFetchData() {
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserLoggedIn && userState.user.role == 'doctor') {
      setState(() {
        _currentDoctorId = userState.user.uid;
        isLoading = true;
        errorMessage = null;
      });
      if (_currentDoctorId != null) {
        _fetchData(_currentDoctorId!);
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Could not retrieve doctor ID.";
        });
      }
    } else {
      setState(() {
        isLoading = false;
        errorMessage = "User is not logged in as a doctor.";
      });
    }
  }

  // Modified to accept doctorId
  Future<void> _fetchData(String doctorId) async {
     if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Fetch data concurrently, passing doctorId where needed
      final results = await Future.wait([
        _db.getNewAppointments(doctorId),
        _db.getTotalPatients(doctorId), // Pass doctorId if method is updated
        _db.getTotalEarnings(doctorId),
        _db.getPatientRegistrations(), // Assuming global for now
        _db.getAppointmentBookings(doctorId: doctorId), // Pass doctorId if method is updated
      ]);

       if (!mounted) return;
      setState(() {
        newAppointments = results[0] as int;
        totalPatients = results[1] as int;
        totalEarnings = results[2] as double;
        registrationsData = results[3] as List<double>;
        bookingsData = results[4] as List<double>;
        isLoading = false;
      });
    } catch (e) {
       if (!mounted) return;
      setState(() {
        errorMessage = "Failed to load data. Tap to retry.";
        isLoading = false;
      });
      debugPrint("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppPallete.primaryColor),
          onPressed: ()  {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/d_dashboard'); // Fallback to doctor dashboard
            }
          },
        ),
        title: const Text(
          "Overview",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppPallete.primaryColor),
        ),
        centerTitle: true,
         actions: [ // Add Refresh button
           IconButton(
             icon: Icon(Icons.refresh, color: AppPallete.primaryColor),
             onPressed: () {
               if (_currentDoctorId != null) {
                 _fetchData(_currentDoctorId!);
               } else {
                 _initializeDoctorAndFetchData(); // Re-initialize if ID was lost
               }
             },
             tooltip: 'Refresh Data',
           ),
         ],
      ),
      backgroundColor: AppPallete.backgroundColor, // Lighter background
      body: _buildBody(),
      // Removed local BottomNavBar, relies on MainLayout
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: AppPallete.primaryColor));
    }

    if (errorMessage != null) {
      return Center(
        child: GestureDetector( // Allow tap to retry
          onTap: () {
             if (_currentDoctorId != null) {
                _fetchData(_currentDoctorId!);
             } else {
                _initializeDoctorAndFetchData();
             }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
                const SizedBox(height: 10),
                const Icon(Icons.refresh, color: AppPallete.primaryColor, size: 30),
                const Text("Tap to retry", style: TextStyle(color: AppPallete.primaryColor)),
              ],
            ),
          ),
        ),
      );
    }

    // Main content when data is loaded
    return RefreshIndicator( // Add pull-to-refresh
       onRefresh: () async {
          if (_currentDoctorId != null) {
             await _fetchData(_currentDoctorId!);
          } else {
             _initializeDoctorAndFetchData();
          }
       },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Ensure scroll works with RefreshIndicator
        child: Padding( // Add overall padding
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildStatsRow(),
              const SizedBox(height: 16), // Consistent spacing
              _buildEarningsCard(),
              const SizedBox(height: 20),
              _buildActivityChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      // Removed Padding wrapper, handled by parent padding
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoCard(
          "New Appointments",
          "$newAppointments",
          "Status: Upcoming", 
          Icons.calendar_today_outlined, 
          Colors.purple,
        ),
        const SizedBox(width: 16), 
        _buildInfoCard(
          "Total Patients",
          "$totalPatients", 
          "Under your care", 
          Icons.people_alt_outlined, 
          Colors.orangeAccent,
        ),
      ],
    );
  }

  Widget _buildEarningsCard() {
    return _buildInfoCard(
      "Total Earnings",
      "\$${totalEarnings.toStringAsFixed(2)}", 
      "All Time", 
      Icons.attach_money,
      Colors.green,
      isFullWidth: true, 
    );
  }

  Widget _buildInfoCard(String title, String value, String subtitle, IconData icon, Color? color, {bool isFullWidth = false}) {
    Widget cardContent = Card(
      elevation: 3, // Reduced elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppPallete.whiteColor, // White background for card
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color ?? AppPallete.primaryColor, size: 24), // Slightly smaller icon
              const SizedBox(width: 8),
              Expanded( // Allow title to wrap
                 child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)), // Adjusted style
              ),
            ]),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)), // Bolder value
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)), // Adjusted style
          ],
        ),
      ),
    );

    return isFullWidth ? cardContent : Expanded(child: cardContent);
  }


  Widget _buildActivityChart() {
    // Define max Y value dynamically, ensuring it's not too small
     double maxY = 10.0; // Default minimum axis height
     if (registrationsData.isNotEmpty || bookingsData.isNotEmpty) {
       final maxReg = registrationsData.isEmpty ? 0.0 : registrationsData.reduce((a, b) => a > b ? a : b);
       final maxBook = bookingsData.isEmpty ? 0.0 : bookingsData.reduce((a, b) => a > b ? a : b);
       maxY = (maxReg > maxBook ? maxReg : maxBook) * 1.2; // Add 20% padding
       if (maxY < 10) maxY = 10.0; // Ensure minimum height of 10
     }


    return Card(
      elevation: 3, // Reduced elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppPallete.whiteColor, // White background
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Daily Activity (Last 7 Days)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)), // Adjusted style
            const SizedBox(height: 16), // Increased spacing
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                      show: true, // Show grid lines
                      drawVerticalLine: false, // Hide vertical lines
                      getDrawingHorizontalLine: (value) { // Style horizontal lines
                         return const FlLine(
                           color: AppPallete.borderColor, // Lighter grid color
                           strokeWidth: 1,
                         );
                      },
                   ),
                  titlesData: FlTitlesData(
                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide top titles
                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide right titles
                    leftTitles: AxisTitles(
                       sideTitles: SideTitles(
                         showTitles: true,
                         reservedSize: 28, // Adjust space for labels
                         interval: maxY / 5 > 1 ? (maxY / 5).roundToDouble() : 1, // Dynamic interval
                         getTitlesWidget: (value, meta) {
                           // Show labels only at intervals
                           if (value % (maxY / 5 > 1 ? (maxY / 5).roundToDouble() : 1) == 0 || value == 0) {
                              return Text(value.toInt().toString(), style: const TextStyle(color: Colors.black54, fontSize: 10));
                           }
                            return const Text('');
                         },
                       ),
                     ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22, // Adjust space
                        interval: 1, // Show every day
                        getTitlesWidget: (value, meta) {
                          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']; // Assuming today is Sun (index 6)
                           int index = value.toInt();
                           if (index >= 0 && index < days.length) {
                             return Padding(
                               padding: const EdgeInsets.only(top: 8.0),
                               child: Text(days[index], style: const TextStyle(color: Colors.black54, fontSize: 10)),
                             );
                           }
                           return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                     show: true,
                     border: Border(
                       bottom: BorderSide(color: AppPallete.borderColor, width: 1), // Border lines
                       left: BorderSide(color: AppPallete.borderColor, width: 1),
                     )
                  ),
                  lineBarsData: [
                    _buildChartBar(registrationsData, AppPallete.primaryColor), // Use consistent color
                    _buildChartBar(bookingsData, Colors.purple),
                  ],
                  minY: 0, // Start Y axis at 0
                   maxY: maxY, // Use calculated max Y
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendDot(AppPallete.primaryColor, "Registrations"),
                const SizedBox(width: 20), // Increased space
                _buildLegendDot(Colors.purple, "Bookings"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildChartBar(List<double> data, Color color) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
      isCurved: true,
      color: color,
      barWidth: 2.5, // Thinner line
       isStrokeCapRound: true, // Rounded ends
      dotData: const FlDotData(show: false), // Hide dots on the line
      belowBarData: BarAreaData( // Add gradient below line
         show: true,
         gradient: LinearGradient(
           colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
           begin: Alignment.topCenter,
           end: Alignment.bottomCenter,
         ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String text) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration( // Smaller dot
          color: color,
          shape: BoxShape.circle,
        )),
        const SizedBox(width: 6), // Adjusted space
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

}
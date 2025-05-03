import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart'; // Import Cubit

import 'package:medical_app/core/themes/color_palette.dart';
import 'earnings_db.dart'; // Ensure this uses the updated DB logic

class EarningsPage extends StatefulWidget {
  const EarningsPage({Key? key}) : super(key: key);

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  // Removed _selectedIndex
  final EarningsDB _db = EarningsDB();
  String? _currentDoctorId; // Store dynamic doctor ID

  List<double> _weeklyRevenue = List.filled(7, 0.0); // Initialize
  int _pendingPaymentsCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDoctorAndLoadData();
    });
  }

 void _initializeDoctorAndLoadData() {
   final userState = context.read<AppUserCubit>().state;
   if (userState is AppUserLoggedIn && userState.user.role == 'doctor') {
     setState(() {
       _currentDoctorId = userState.user.uid;
       _isLoading = true;
       _errorMessage = null;
     });
     if (_currentDoctorId != null) {
       _loadData(_currentDoctorId!);
     } else {
       setState(() {
         _isLoading = false;
         _errorMessage = "Could not retrieve doctor ID.";
       });
     }
   } else {
     setState(() {
       _isLoading = false;
       _errorMessage = "User is not logged in as a doctor.";
     });
   }
 }


  // Modified to accept doctorId
  Future<void> _loadData(String doctorId) async {
     if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Fetch data concurrently, passing doctorId
      final results = await Future.wait([
        _db.getWeeklyRevenue(doctorId),
        _db.getPendingPaymentsCount(doctorId),
      ]);

      // Process results safely
      final dynamic revenueData = results[0];
      final dynamic paymentsData = results[1];

      final List<double> revenueList = (revenueData is List)
          ? revenueData.map((e) {
              if (e is double) return e;
              if (e is int) return e.toDouble();
              return 0.0;
            }).toList()
          : List.filled(7, 0.0); // Default if type is wrong

       final int paymentsCount = paymentsData is int
           ? paymentsData
           : int.tryParse(paymentsData.toString()) ?? 0; // Default if type is wrong

       if (!mounted) return;
      setState(() {
        _weeklyRevenue = revenueList;
        _pendingPaymentsCount = paymentsCount;
        _isLoading = false;
      });
    } catch (e) {
       if (!mounted) return;
      setState(() {
        // Set defaults on error
        _weeklyRevenue = List.filled(7, 0.0);
        _pendingPaymentsCount = 0;
        _isLoading = false;
        _errorMessage = "Failed to load earnings data."; // Set error message
      });
      debugPrint("Error loading earnings data: $e");
       ScaffoldMessenger.of(context).showSnackBar( // Show snackbar error
         SnackBar(content: Text('Error: $_errorMessage')),
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.whiteColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Earnings",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppPallete.primaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppPallete.primaryColor,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/d_dashboard'); // Fallback to doctor dashboard
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppPallete.primaryColor),
            onPressed: () {
               if (_currentDoctorId != null) {
                 _loadData(_currentDoctorId!);
               } else {
                 _initializeDoctorAndLoadData(); // Re-initialize if ID was lost
               }
            },
             tooltip: 'Refresh Data',
          ),
        ],
      ),
      backgroundColor: AppPallete.backgroundColor, // Lighter background
      body: _buildBody(), // Separate body building logic
      // Removed local BottomNavBar, relies on MainLayout
    );
  }

 Widget _buildBody() {
   if (_isLoading) {
     return const Center(child: CircularProgressIndicator(color: AppPallete.primaryColor));
   }
   if (_errorMessage != null) {
     return Center(
        child: GestureDetector( // Allow tap to retry
          onTap: () {
             if (_currentDoctorId != null) {
                _loadData(_currentDoctorId!);
             } else {
                _initializeDoctorAndLoadData();
             }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
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
           await _loadData(_currentDoctorId!);
        } else {
           _initializeDoctorAndLoadData();
        }
     },
     child: SingleChildScrollView( // Make content scrollable
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding( // Add overall padding
          padding: const EdgeInsets.all(16.0),
          child: Column(
             children: [
               _buildRevenueChart(),
               const SizedBox(height: 20),
               _buildPendingPaymentsCard(),
             ],
           ),
        ),
     ),
   );
 }


  Widget _buildRevenueChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxY = _weeklyRevenue.isNotEmpty
        ? _weeklyRevenue.reduce((a, b) => a > b ? a : b) * 1.2 // Add 20% padding
        : 50.0; // Default height if no data
     final minY = 0.0;

    return Card(
      elevation: 3, // Softer shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppPallete.whiteColor, // White card background
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10), // Adjust padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Weekly Earnings",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.textColor,
                  ),
                ),
                 Text(
                  "Last 7 Days", // More specific
                  style: TextStyle(
                    fontSize: 14,
                    color: AppPallete.greyColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // More space before chart
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                   gridData: FlGridData( // Custom grid
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => const FlLine(
                        color: AppPallete.borderColor,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35, // Space for labels
                          interval: maxY / 4 > 1 ? (maxY / 4).roundToDouble() : 1, // Dynamic interval
                          getTitlesWidget: (value, meta) {
                            if (value == minY || value == maxY || value % (maxY / 4 > 1 ? (maxY / 4).roundToDouble() : 1) == 0) {
                              return Text('\$${value.toInt()}', style: const TextStyle(color: Colors.black54, fontSize: 10));
                            }
                            return const Text('');
                           },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                           interval: 1,
                          getTitlesWidget: (value, meta) {
                             int index = value.toInt();
                             if (index >= 0 && index < days.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(days[index], style: const TextStyle(fontSize: 10, color: Colors.black54)),
                                );
                             }
                             return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData( // Custom border
                       show: true,
                       border: Border(
                         bottom: BorderSide(color: AppPallete.borderColor, width: 1),
                         left: BorderSide(color: AppPallete.borderColor, width: 1),
                       ),
                     ),
                    minX: 0,
                    maxX: 6,
                    minY: minY,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: _weeklyRevenue.asMap().entries.map(
                              (e) => FlSpot(e.key.toDouble(), e.value),
                        ).toList(),
                        isCurved: true,
                        color: AppPallete.primaryColor,
                        barWidth: 2.5, // Thinner line
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false), // Hide dots
                         belowBarData: BarAreaData( // Gradient fill
                           show: true,
                           gradient: LinearGradient(
                             colors: [
                               AppPallete.primaryColor.withOpacity(0.3),
                               AppPallete.primaryColor.withOpacity(0.0),
                             ],
                             begin: Alignment.topCenter,
                             end: Alignment.bottomCenter,
                           ),
                         ),
                      ),
                    ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Total: \$${_weeklyRevenue.fold<double>(0, (sum, e) => sum + e).toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16, // Slightly smaller total
                  fontWeight: FontWeight.bold,
                  color: AppPallete.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingPaymentsCard() {
    return Card(
      elevation: 3, // Softer shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppPallete.whiteColor, // White card background
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10), // Adjusted padding
              decoration: BoxDecoration(
                color: AppPallete.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_bottom, // More relevant icon
                  color: AppPallete.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pending Payments",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppPallete.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _pendingPaymentsCount > 0
                        ? "$_pendingPaymentsCount payment${_pendingPaymentsCount == 1 ? '' : 's'} pending" // Pluralization
                        : "No pending payments",
                    style: TextStyle(
                      fontSize: 16, // Adjusted size
                      color: _pendingPaymentsCount > 0
                          ? Colors.orange.shade700 // Orange for pending
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppPallete.greyColor), // Indicate action possible
          ],
        ),
      ),
    );
  }

  // Removed local BottomNavBar build method
}
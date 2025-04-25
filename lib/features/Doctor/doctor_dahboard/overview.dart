import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'OveviewDB.dart';

class OverviewPage extends StatefulWidget {
  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  int _selectedIndex = 0;
  final OverviewDB _db = OverviewDB();

  // State variables
  int newAppointments = 0;
  int totalPatients = 0;
  double totalEarnings = 0.0;
  List<double> registrationsData = [];
  List<double> bookingsData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _db.getNewAppointments(),
        _db.getTotalPatients(),
        _db.getTotalEarnings(),
        _db.getPatientRegistrations(),
        _db.getAppointmentBookings(),
      ]);

      setState(() {
        newAppointments = results[0] as int;
        totalPatients = results[1] as int;
        totalEarnings = results[2] as double;
        registrationsData = results[3] as List<double>;
        bookingsData = results[4] as List<double>;
        isLoading = false;
      });
    } catch (e) {
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Overview",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppPallete.primaryColor),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppPallete.whiteColor,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: AppPallete.primaryColor));
    }

    if (errorMessage != null) {
      return Center(
        child: GestureDetector(
          onTap: _fetchData,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!, style: TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              Icon(Icons.refresh, color: AppPallete.primaryColor),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildStatsRow(),
          const SizedBox(height: 10),
          _buildEarningsCard(),
          const SizedBox(height: 20),
          _buildActivityChart(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoCard(
            "New Appointments",
            "$newAppointments+",
            "26 are waiting",
            Icons.calendar_today,
            Colors.purple,
          ),
          _buildInfoCard(
            "Total Patients",
            "$totalPatients+",
            "150 increase",
            Icons.people,
            Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: _buildInfoCard(
        "Total Earnings",
        "\$${totalEarnings.toStringAsFixed(2)}+",
        "36% increase",
        Icons.attach_money,
        Colors.green,
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, String subtitle, IconData icon, Color? color) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, color: color ?? AppPallete.primaryColor, size: 28),
                const SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
              ]),
              const SizedBox(height: 10),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Daily Activity (Last 7 Days)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final days = ['6d', '5d', '4d', '3d', '2d', '1d', 'Today'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(days[value.toInt()], style: TextStyle(color: Colors.black)),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      _buildChartBar(registrationsData, AppPallete.primaryColor),
                      _buildChartBar(bookingsData, Colors.purple),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendDot(AppPallete.primaryColor, "Registrations"),
                  const SizedBox(width: 16),
                  _buildLegendDot(Colors.purple, "Bookings"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  LineChartBarData _buildChartBar(List<double> data, Color color) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildLegendDot(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        )),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black)),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      selectedItemColor: AppPallete.primaryColor,
      unselectedItemColor: AppPallete.greyColor,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ""),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'earnings_db.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({Key? key}) : super(key: key);

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  int _selectedIndex = 0;
  final EarningsDB _db = EarningsDB();
  List<double> _weeklyRevenue = [];
  bool _isLoading = true;
  int _pendingPaymentsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final dynamic revenueData = await _db.getWeeklyRevenue();
      final dynamic paymentsData = await _db.getPendingPaymentsCount();

      // Convert dynamic list to List<double>
      _weeklyRevenue = (revenueData as List).map((e) {
        if (e is double) return e;
        if (e is int) return e.toDouble();
        return 0.0;
      }).toList();

      // Convert dynamic to int
      _pendingPaymentsCount = paymentsData is int
          ? paymentsData
          : int.tryParse(paymentsData.toString()) ?? 1;

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _weeklyRevenue = List.filled(7, 0.0);
        _pendingPaymentsCount = 1;
        _isLoading = false;
      });
      debugPrint("Error loading data: $e");
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
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppPallete.primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppPallete.primaryColor),
            onPressed: _loadData,
          ),
        ],
      ),
      backgroundColor: AppPallete.whiteColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppPallete.primaryColor))
          : Column(
        children: [
          const SizedBox(height: 20),
          _buildRevenueChart(),
          const SizedBox(height: 20),
          _buildPendingPaymentsCard(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
      ),
    );
  }

  Widget _buildRevenueChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxY = _weeklyRevenue.isNotEmpty
        ? _weeklyRevenue.reduce((a, b) => a > b ? a : b) * 1.2
        : 100.0;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Weekly Earnings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppPallete.textColor,
                    ),
                  ),
                  Text(
                    "This Week",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppPallete.greyColor,
                    ),
                  ),
                ],
              ),
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
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[value.toInt()],
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: _weeklyRevenue.asMap().entries.map(
                              (e) => FlSpot(e.key.toDouble(), e.value),
                        ).toList(),
                        isCurved: true,
                        color: AppPallete.primaryColor,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppPallete.primaryColor.withOpacity(0.1),
                        ),
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "\$${_weeklyRevenue.fold<double>(0, (sum, e) => sum + e).toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingPaymentsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppPallete.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.payment,
                    color: AppPallete.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
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
                          ? "$_pendingPaymentsCount pending"
                          : "No pending payments",
                      style: TextStyle(
                        fontSize: 18,
                        color: _pendingPaymentsCount > 0
                            ? AppPallete.primaryColor
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: AppPallete.greyColor),
            ],
          ),
        ),
      ),
    );
  }
}
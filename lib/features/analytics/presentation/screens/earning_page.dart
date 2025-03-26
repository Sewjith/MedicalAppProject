import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:medical_app/features/analytics/doctor_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorEarningsPage extends StatefulWidget {
  final String? doctorId;

  const DoctorEarningsPage({Key? key, this.doctorId}) : super(key: key);

  @override
  _DoctorEarningsPageState createState() => _DoctorEarningsPageState();
}

class _DoctorEarningsPageState extends State<DoctorEarningsPage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? doctorData;
  List<Map<String, dynamic>> earningsData = [];
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Use provided doctorId or fallback to current user
      final userId = widget.doctorId ?? supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'No doctor specified and not logged in';
        });
        return;
      }

      // Fetch doctor profile data
      final doctorResponse = await supabase
          .from('doctors')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (doctorResponse == null) {
        throw Exception('Doctor not found');
      }

      // Fetch earnings data
      final earningsResponse = await supabase
          .from('earnings')
          .select()
          .eq('doctor_id', userId)
          .order('date', ascending: false);
      
      // Create transactions from earnings data
      final transactionList = earningsResponse.map((e) => {
        'date': e['date']?.toString() ?? '',
        'amount': 'Rs. ${e['total_earnings']?.toStringAsFixed(2) ?? '0'}',
        'patient': '${e['no_of_consultations'] ?? 0} Consultations',
        'consultations': e['no_of_consultations'] ?? 0,
      }).toList();

      setState(() {
        doctorData = doctorResponse;
        earningsData = List<Map<String, dynamic>>.from(earningsResponse);
        transactions = transactionList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Earnings Overview'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (doctorData != null) _buildDoctorCard(),
              SizedBox(height: 20),
              _buildTotalEarnings(),
              SizedBox(height: 20),
              Text('Monthly Earnings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildEarningsChart(),
              SizedBox(height: 20),
              Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                height: 300,
                child: _buildTransactionList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard() {
    return DoctorCard(
      doctorImagePath: "assets/images/doc3.jpg",
      rating: "4.5",
      doctorName: "Dr. ${doctorData?['first_name']} ${doctorData?['last_name']}",
      doctorProfession: doctorData?['specialty'] ?? 'Doctor',
      DoctorEarning: "Rs. ${_calculateTotalEarnings().toStringAsFixed(2)}",
    );
  }

  double _calculateTotalEarnings() {
    if (earningsData.isEmpty) return 0;
    return earningsData
        .map((e) => (e['total_earnings'] as num?)?.toDouble() ?? 0)
        .reduce((a, b) => a + b);
  }

  Widget _buildTotalEarnings() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Earnings', style: TextStyle(color: Colors.white, fontSize: 16)),
          SizedBox(height: 8),
          Text(
            'Rs. ${_calculateTotalEarnings().toStringAsFixed(2)}',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsChart() {
    final monthlyData = _groupEarningsByMonth();

    return Container(
      height: 200,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 1 && value <= 12 && value == value.toInt()) {
                    return Text(
                      _getMonthAbbreviation(value.toInt()),
                      style: TextStyle(fontSize: 10),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: monthlyData.entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value);
              }).toList(),
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, double> _groupEarningsByMonth() {
    final result = <int, double>{};
    
    for (var earning in earningsData) {
      final dateStr = earning['date'];
      if (dateStr != null) {
        final date = DateTime.parse(dateStr);
        final month = date.month;
        final amount = (earning['total_earnings'] as num?)?.toDouble() ?? 0;
        
        result.update(month, (value) => value + amount, ifAbsent: () => amount);
      }
    }
    
    for (var i = 1; i <= 12; i++) {
      result.putIfAbsent(i, () => 0);
    }
    
    return result;
  }

  String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildTransactionList() {
    if (transactions.isEmpty) {
      return Center(child: Text('No transactions found'));
    }
    
    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (_, __) => Divider(),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return ListTile(
          leading: Icon(Icons.monetization_on, color: Colors.green),
          title: Text(transaction['patient']),
          subtitle: Text(transaction['date']),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(transaction['amount'], style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${transaction['consultations']} consults', style: TextStyle(fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}
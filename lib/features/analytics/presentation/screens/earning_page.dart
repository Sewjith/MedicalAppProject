import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:medical_app/features/analytics/doctor_card.dart';

class DoctorEarningsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          DoctorCard(
            doctorImagePath: "assets/images/doc3.jpg",
            rating: "4.5",
            doctorName: "Dr. Jake Doe",
            doctorProfession: "Dentist",
            DoctorEarning: "Rs. 500,000",
          ),
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
            height: 300, // Adjust height as needed
            child: _buildTransactionList(),
          ),
        ],
      ),
    ),
  ),
);

  }

  Widget _buildDoctorCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.deepPurple[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            DoctorCard(
          doctorImagePath: "lib/Images/doc2.jpg",
          rating: "4.5",
          doctorName: "Dr. Jake Doe",
          doctorProfession: "Dentist",
          DoctorEarning: "Rs. 500,000",
        ),
          ],
        ),
      ),
    );
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
          Text('\$12,450', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEarningsChart() {
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
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(1, 500),
                FlSpot(2, 1200),
                FlSpot(3, 1500),
                FlSpot(4, 1800),
                FlSpot(5, 2200),
                FlSpot(6, 2500),
              ],
              isCurved: true,
              //colors: [Colors.blueAccent],
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    final transactions = [
      {'date': 'Feb 25', 'amount': '\$300', 'patient': 'John Doe'},
      {'date': 'Feb 24', 'amount': '\$150', 'patient': 'Jane Smith'},
      {'date': 'Feb 23', 'amount': '\$200', 'patient': 'Michael Johnson'},
    ];

    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (_, __) => Divider(),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return ListTile(
          leading: Icon(Icons.monetization_on, color: Colors.green),
          title: Text(transaction['patient']!),
          subtitle: Text(transaction['date']!),
          trailing: Text(transaction['amount']!, style: TextStyle(fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DoctorEarningsPage(),
  ));
}

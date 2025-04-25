import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';

class AppointmentConfirmationPage extends StatelessWidget {
  final String name;
  final String age;
  final String gender;
  final String date;
  final String time;
  final String doctor;
  final String problem;
  final VoidCallback onConfirm; 

  const AppointmentConfirmationPage({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.date,
    required this.time,
    required this.doctor,
    required this.problem,
    required this.onConfirm, 
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        title: const Text("Your Appointment", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppPallete.primaryColor,
        elevation: 0,
        foregroundColor: AppPallete.whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Appointment Confirmation",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppPallete.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            _dateTimeSection(),
            const SizedBox(height: 24),
            _divider(),
            const SizedBox(height: 24),

            _infoSection("Full Name", name),
            _infoSection("Age", age),
            _infoSection("Gender", gender),
            _infoSection("Doctor", doctor),
            const SizedBox(height: 16),
            _problemDescriptionSection(),
            const SizedBox(height: 24),
            _actionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppPallete.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: AppPallete.greyColor.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _dateTimeColumn("Date", date.split(' ')[0]),
          _dateTimeColumn("Time", time),
        ],
      ),
    );
  }

  Widget _dateTimeColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPallete.headings),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, color: AppPallete.textColor),
        ),
      ],
    );
  }

  Widget _divider() {
    return Divider(
      color: AppPallete.borderColor,
      thickness: 1,
    );
  }

  Widget _infoSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppPallete.textColor)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPallete.textColor)),
        ],
      ),
    );
  }

  Widget _problemDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Problem Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPallete.headings)),
          const SizedBox(height: 8),
          Text(
            problem.isEmpty ? "No description provided" : problem,
            style: TextStyle(fontSize: 14, color: AppPallete.textColor),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.errorColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
            child: const Text("Cancel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _showConfirmationDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
            child: const Text("Confirm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 10),
              const Text("Appointment Confirmed", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: const Text("Your appointment has been successfully confirmed.", style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                onConfirm();
                
                Navigator.pop(context);
                Navigator.pop(context); 
              },
              child: const Text("OK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
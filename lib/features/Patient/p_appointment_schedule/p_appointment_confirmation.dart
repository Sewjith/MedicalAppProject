import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Import for date formatting if needed elsewhere
import 'package:medical_app/core/themes/color_palette.dart';

class AppointmentConfirmationPage extends StatelessWidget {
  final String name;
  final String age;
  final String gender;
  final String date; // Expecting formatted date string e.g., "MMM dd, yyyy"
  final String time;
  final String doctor; // Expecting doctor display name
  final String problem;
  final VoidCallback onConfirm;

  const AppointmentConfirmationPage({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.date, // Should be pre-formatted
    required this.time,
    required this.doctor, // Display name passed from previous screen
    required this.problem,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        title: const Text("Review Appointment", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppPallete.primaryColor,
        elevation: 0,
        foregroundColor: AppPallete.whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Simple back navigation
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Please confirm your details:", // Changed title
              style: TextStyle(
                fontSize: 22, // Adjusted size
                fontWeight: FontWeight.bold,
                color: AppPallete.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            _dateTimeSection(),
            const SizedBox(height: 24),
            _divider(),
            const SizedBox(height: 24),

            _infoSection("Doctor", doctor), // Display doctor name
            _infoSection("Patient Name", name),
            _infoSection("Age", age),
            _infoSection("Gender", gender),
            const SizedBox(height: 16),
            _problemDescriptionSection(),
            const Spacer(), // Push buttons to bottom
            _actionButtons(context),
            const SizedBox(height: 16), // Padding at bottom
          ],
        ),
      ),
    );
  }

  Widget _dateTimeSection() {
    return Container(
      padding: const EdgeInsets.all(16.0), // Adjusted padding
      decoration: BoxDecoration(
        color: AppPallete.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           // Show Icon for clarity
           const Icon(Icons.calendar_today_outlined, color: AppPallete.primaryColor, size: 20),
           const SizedBox(width: 8),
           Expanded(child: _dateTimeColumn("Date", date)), // Use Expanded
           const SizedBox(width: 16), // Spacer
           const Icon(Icons.access_time_outlined, color: AppPallete.primaryColor, size: 20),
           const SizedBox(width: 8),
           Expanded(child: _dateTimeColumn("Time", time)), // Use Expanded
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
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppPallete.headings.withOpacity(0.8)), // Softer label
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: AppPallete.textColor, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _divider() {
    return Divider(
      color: AppPallete.borderColor.withOpacity(0.5), // Softer divider
      thickness: 1,
    );
  }

  Widget _infoSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10), // Adjusted padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppPallete.textColor.withOpacity(0.8))), // Softer title
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppPallete.textColor)),
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
            style: TextStyle(fontSize: 14, color: AppPallete.textColor, height: 1.4), // Improved line height
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton( // Use OutlinedButton for cancel
            onPressed: () => Navigator.pop(context), // Just go back
            style: OutlinedButton.styleFrom(
              foregroundColor: AppPallete.errorColor, // Text color
              side: const BorderSide(color: AppPallete.errorColor), // Border color
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Cancel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _showConfirmationDialog(context); // Show dialog before saving
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
              foregroundColor: AppPallete.whiteColor, // Text color
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: const Text("Confirm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // Show confirmation dialog, then call onConfirm and navigate back
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 10),
              const Text("Appointment Confirmed!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: const Text(
             "Your appointment has been successfully booked. You will receive a notification reminder.",
             textAlign: TextAlign.center,
             style: TextStyle(fontSize: 15),
           ),
          actionsAlignment: MainAxisAlignment.center, // Center the button
          actions: [
            TextButton(
              onPressed: () {
                 Navigator.of(context).pop(); // Close the dialog FIRST
                 onConfirm(); // Call the save function
   
                 if(context.canPop()) context.pop(); // Pop confirmation page
                 if(context.canPop()) context.pop(); // Pop schedule page
            
                 context.go('/patient/appointment/history');
              },
              child: const Text("OK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
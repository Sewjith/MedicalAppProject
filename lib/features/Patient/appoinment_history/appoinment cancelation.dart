//@annotate:rewritten:lib/features/Patient/appoinment_history/appoinment cancelation.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter for navigation and state access
import 'package:medical_app/core/themes/color_palette.dart';
// Import the file containing the embedded AppointmentHistoryDb class
import 'package:medical_app/features/Patient/appoinment_history/appoinment.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

// Removed main() and outer MaterialApp wrapper as this is a page within the app

class CancelAppointmentPage extends StatefulWidget {
  // Constructor remains simple, ID is expected via GoRouter's extra
  const CancelAppointmentPage({super.key});

  @override
  _CancelAppointmentPageState createState() => _CancelAppointmentPageState();
}

class _CancelAppointmentPageState extends State<CancelAppointmentPage> {
  // State variable to hold the selected reason
  String selectedReason = 'Rescheduling'; // Default selection
  // Controller for the "Others" reason details TextField
  final TextEditingController _detailsController = TextEditingController();
  // Loading state for the submission button
  bool _isSubmitting = false;
  // Instance of the DB class (defined in appoinment.dart)
  final AppointmentHistoryDb _db = AppointmentHistoryDb();

  @override
  void dispose() {
    _detailsController.dispose(); // Dispose the controller
    super.dispose();
  }

  // --- Function to handle the actual cancellation ---
  Future<void> _submitCancellation() async {
    // Retrieve the appointment ID passed via GoRouter's 'extra' parameter
    final String? appointmentId = GoRouterState.of(context).extra as String?;

    // Validate if appointmentId was received
    if (appointmentId == null || appointmentId.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Error: Could not identify appointment to cancel.'), backgroundColor: Colors.red),
       );
       return;
    }

    // Prepare the reason string
    String reasonDetails = selectedReason;
    // If "Others" is selected, validate and use the text field content
    if (selectedReason == 'Others') {
      if (_detailsController.text.trim().isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Please provide details for "Others".'), backgroundColor: Colors.orange),
         );
         return; // Stop submission if details are missing for "Others"
      }
      reasonDetails = _detailsController.text.trim();
    }

    // Set loading state
    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      // Call the cancelAppointment method from the DB class
      await _db.cancelAppointment(appointmentId, reasonDetails);

      if (!mounted) return; // Check again before showing SnackBar/popping
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled successfully.'), backgroundColor: Colors.green),
      );
      // Pop back to the previous screen (likely Upcoming list)
      context.pop();
      // Note: The previous screen (Upcoming list) will need a refresh mechanism
      // to reflect the change immediately (e.g., pull-to-refresh or state management).

    } catch (e) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error cancelling appointment: ${e.toString().replaceFirst("Exception: ","")}'), backgroundColor: Colors.red),
       );
    } finally {
       // Ensure loading state is reset even if an error occurs
       if (mounted) {
         setState(() => _isSubmitting = false);
       }
    }
  }
  // --- End cancellation function ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        backgroundColor: AppPallete.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppPallete.primaryColor),
                onPressed: ()  {
            // Use context.pop() for GoRouter navigation back
            if (context.canPop()) {
              context.pop();
            } else {
              // Fallback if it cannot pop (e.g., deep linked)
              context.go('/patient/appointment/history'); // Go back to history base
            } 
          },
        ),
        centerTitle: true,
        title: const Text(
          'Cancel Appointment',
          style: TextStyle(
            color: AppPallete.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Allows scrolling if content overflows
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please select the reason for cancelling your appointment.',
                style: TextStyle(fontSize: 14, color: AppPallete.textColor),
              ),
              const SizedBox(height: 20),
              // Use a Column for RadioListTiles
              Column(
                 children: [
                    _buildRadioButton('Rescheduling'),
                    _buildRadioButton('Weather Conditions'),
                    _buildRadioButton('Unexpected Work'),
                    _buildRadioButton('Others'), // Selecting this shows the TextField
                 ]
              ),
              const SizedBox(height: 20),

              // Conditionally display the TextField for "Others" reason
              if (selectedReason == 'Others')
                Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      const Text(
                        'Please provide specific reason:',
                        style: TextStyle(fontSize: 14, color: AppPallete.primaryColor),
                      ),
                      const SizedBox(height: 10),
                      TextField( // The text input box for "Others"
                         controller: _detailsController,
                         maxLines: 5,
                         decoration: InputDecoration(
                          hintText: 'Enter Your Reason Here…',
                          filled: true,
                          fillColor: Colors.blue.shade50, // Light background
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none, // No border
                          ),
                         ),
                      ),
                      const SizedBox(height: 20), // Add space after TextField
                   ],
                ),

              // Confirmation Button
              Center(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitCancellation, // Disable while submitting
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor, // Button color
                    foregroundColor: AppPallete.whiteColor, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: _isSubmitting
                      // Show loading indicator when submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      // Show button text otherwise
                      : const Text(
                          'Confirm Cancellation',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      // No BottomNavigationBar here, assuming it's handled by MainLayout/ShellRoute
    );
  }

  // Helper widget for creating RadioListTiles
  Widget _buildRadioButton(String title) {
    return RadioListTile<String>(
      title: Text(title),
      value: title,
      groupValue: selectedReason, // Tracks the currently selected value
      activeColor: AppPallete.primaryColor, // Color when selected
      onChanged: (value) {
        // Update the state when a radio button is tapped
        if (value != null) {
          setState(() {
            selectedReason = value;
          });
        }
      },
      // Optional styling for better appearance
      tileColor: selectedReason == title ? AppPallete.primaryColor.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}

// Removed redundant BottomNavBar class definition
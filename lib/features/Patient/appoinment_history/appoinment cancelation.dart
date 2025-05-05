import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/Patient/appoinment_history/appoinment.dart';
import 'package:flutter/foundation.dart'; // For debugPrint


class CancelAppointmentPage extends StatefulWidget {

  const CancelAppointmentPage({super.key});

  @override
  _CancelAppointmentPageState createState() => _CancelAppointmentPageState();
}

class _CancelAppointmentPageState extends State<CancelAppointmentPage> {

  String selectedReason = 'Rescheduling'; 
  final TextEditingController _detailsController = TextEditingController();
  
  bool _isSubmitting = false;

  final AppointmentHistoryDb _db = AppointmentHistoryDb();

  @override
  void dispose() {
    _detailsController.dispose(); 
    super.dispose();
  }


  Future<void> _submitCancellation() async {

    final String? appointmentId = GoRouterState.of(context).extra as String?;

    if (appointmentId == null || appointmentId.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Error: Could not identify appointment to cancel.'), backgroundColor: Colors.red),
       );
       return;
    }


    String reasonDetails = selectedReason;

    if (selectedReason == 'Others') {
      if (_detailsController.text.trim().isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Please provide details for "Others".'), backgroundColor: Colors.orange),
         );
         return; 
      }
      reasonDetails = _detailsController.text.trim();
    }


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

            if (context.canPop()) {
              context.pop();
            } else {
     
              context.go('/patient/appointment/history'); 
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
                    _buildRadioButton('Others'), 
                 ]
              ),
              const SizedBox(height: 20),


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


              Center(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitCancellation, 
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

    );
  }

  Widget _buildRadioButton(String title) {
    return RadioListTile<String>(
      title: Text(title),
      value: title,
      groupValue: selectedReason, // Tracks the currently selected value
      activeColor: AppPallete.primaryColor, // Color when selected
      onChanged: (value) {

        if (value != null) {
          setState(() {
            selectedReason = value;
          });
        }
      },
 
      tileColor: selectedReason == title ? AppPallete.primaryColor.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}


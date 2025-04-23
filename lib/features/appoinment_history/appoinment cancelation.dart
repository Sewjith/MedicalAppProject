import 'package:flutter/material.dart';
import 'package:medical_app/features/appoinment_history/upcoming.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CancelAppointmentPage extends StatefulWidget {
  final String appointmentId; // UUID from appointments.id

  const CancelAppointmentPage({Key? key, required this.appointmentId})
      : super(key: key);

  @override
  _CancelAppointmentPageState createState() => _CancelAppointmentPageState();
}

class _CancelAppointmentPageState extends State<CancelAppointmentPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  String selectedReason = 'Weather Conditions';
  String additionalDetails = '';
  int _selectedIndex = 0;
  bool _isSubmitting = false;

  Future<void> _submitCancellation() async {
    setState(() => _isSubmitting = true);

    try {
      // 1. Get the appointment_id (varchar) that corresponds to the UUID
      final appointment = await _supabase
          .from('appointments')
          .select('appointment_id') // SINGULAR form
          .eq('id', widget.appointmentId)
          .single();

      final referenceId = appointment['appointment_id'].toString();
      debugPrint('Using reference ID: $referenceId');

      // 2. Update appointment status (using UUID)
      await _supabase
          .from('appointments')
          .update({'appointment_status': 'cancelled'})
          .eq('id', widget.appointmentId);

      // 3. Create cancellation record (using varchar appointment_id)
      await _supabase.from('appointment_cancellations').insert({
        'appointment_id': referenceId,
        'reason': selectedReason,
        'additional_details': additionalDetails.isNotEmpty ? additionalDetails : null,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment cancelled successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Upcoming()),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('PostgrestException', '')}'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Cancellation error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
          icon: Icon(Icons.arrow_back_ios, color: AppPallete.primaryColor),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Upcoming()),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Cancel Appointment',
          style: TextStyle(
            color: AppPallete.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select cancellation reason:',
              style: TextStyle(
                fontSize: 16,
                color: AppPallete.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16),
            _buildReasonTile('Rescheduling'),
            _buildReasonTile('Weather Conditions'),
            _buildReasonTile('Unexpected Work'),
            _buildReasonTile('Others'),
            SizedBox(height: 24),
            Text(
              'Additional details (optional):',
              style: TextStyle(
                fontSize: 16,
                color: AppPallete.primaryColor,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Explain if needed...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => additionalDetails = value,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitCancellation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  'CONFIRM CANCELLATION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonTile(String reason) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: selectedReason == reason
            ? AppPallete.primaryColor.withOpacity(0.1)
            : Colors.grey[50],
        leading: Radio<String>(
          value: reason,
          groupValue: selectedReason,
          onChanged: (value) => setState(() => selectedReason = value!),
          activeColor: AppPallete.primaryColor,
        ),
        title: Text(
          reason,
          style: TextStyle(
            fontSize: 15,
            color: AppPallete.textColor,
          ),
        ),
        onTap: () => setState(() => selectedReason = reason),
      ),
    );
  }
}
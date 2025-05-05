// File: lib/features/Patient/appoinment_history/details.dart
// @annotate:modified:lib/features/Patient/appoinment_history/details.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/Patient/appoinment_history/appoinment.dart'; // Import the DB class
import 'package:cached_network_image/cached_network_image.dart'; // For doctor image
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:url_launcher/url_launcher.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final String appointmentId; // Accept only appointmentId

  const AppointmentDetailsPage({
    Key? key,
    required this.appointmentId,
  }) : super(key: key);

  @override
  _AppointmentDetailsPageState createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  final AppointmentHistoryDb _db = AppointmentHistoryDb(); // Use the DB class
  Map<String, dynamic>? _appointmentData; // State to hold fetched data
  bool _isLoading = true;
  String? _errorMessage;
  String? _prescriptionPdfUrl;

  @override
  void initState() {
    super.initState();
    _fetchAppointmentDetails();
  }

  Future<void> _fetchAppointmentDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _prescriptionPdfUrl = null;
    });
    try {
      final data = await _db.getAppointmentDetails(widget.appointmentId);
      if (mounted) {
        setState(() {
          _appointmentData = data;
          _prescriptionPdfUrl = data['prescription_pdf_url'] as String?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
        });
      }
    }
  }

  Future<void> _launchPrescriptionUrl() async {
    if (_prescriptionPdfUrl == null || _prescriptionPdfUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No prescription URL found.')),
      );
      return;
    }

    final Uri url = Uri.parse(_prescriptionPdfUrl!);
    try {
      bool launched = await launchUrl(
        url,
        mode: LaunchMode
            .externalApplication, // Try opening in external app/browser
      );
      if (!launched) {
        debugPrint('Could not launch $url');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open prescription: $url')),
        );
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error opening prescription link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.whiteColor,
        elevation: 1,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: AppPallete.primaryColor),
          onPressed: () {
            // Use GoRouter's pop for navigation consistency
            if (context.canPop()) {
              context.pop();
            } else {
              // Fallback if cannot pop (e.g., deep link)
              context.go('/patient/appointment/history');
            }
          },
        ),
        title: const Text(
          'Appointment Details',
          style: TextStyle(
              color: AppPallete.primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error: $_errorMessage',
                          style: const TextStyle(color: Colors.red))))
              : _appointmentData == null
                  ? const Center(child: Text('Appointment details not found.'))
                  : _buildDetailsContent(), // Extracted content build logic
    );
  }

  Widget _buildDetailsContent() {
    final doctorData = _appointmentData!['doctor'] as Map<String, dynamic>?;
    final doctorName = _db.getDoctorDisplayName(doctorData);
    final specialty = doctorData?['specialty'] ?? 'N/A';
    final avatarUrl = _db.getDoctorAvatarUrl(doctorData);
    final formattedDateTime = _db.formatAppointmentDateTime(
      _appointmentData!['appointment_date'],
      _appointmentData!['appointment_time'],
    );
    final status = _appointmentData!['appointment_status'] ?? 'Unknown';
    final paymentStatus = _appointmentData!['Payment Status'] ?? 'unknown';
    final notes = _appointmentData!['notes'] ?? 'No description provided.';
    final patientName = _appointmentData!['patient_name'] ?? 'N/A';
    final patientAge = _appointmentData!['patient_age']?.toString() ?? 'N/A';
    final patientGender = _appointmentData!['patient_gender'] ?? 'N/A';
    final displayAppointmentId =
        _appointmentData!['appointment_id'] ?? widget.appointmentId;

    return SingleChildScrollView(
      // Make content scrollable
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Info Card
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: avatarUrl != null
                        ? CachedNetworkImageProvider(avatarUrl)
                        : const AssetImage(
                                'assets/images/doctor_placeholder.png')
                            as ImageProvider,
                    onBackgroundImageError: (_, __) {
                      debugPrint("Error loading image: $avatarUrl");
                    },
                    child: avatarUrl == null
                        ? const Icon(Icons.person, size: 35, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppPallete.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          specialty,
                          style: TextStyle(
                              fontSize: 15,
                              color: AppPallete.textColor.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Appointment Details Section
          _buildSectionTitle("Appointment Information"),
          _buildDetailItem(
              Icons.calendar_today_outlined, "Date & Time", formattedDateTime),
          _buildDetailItem(Icons.confirmation_num_outlined, "Appointment ID",
              widget.appointmentId),
          _buildDetailItem(
            Icons.info_outline,
            "Status",
            status,
            valueColor: _getStatusColor(status),
          ),
          _buildDetailItem(
            Icons.payment_outlined,
            "Payment Status",
            paymentStatus,
            valueColor: _getPaymentStatusColor(paymentStatus),
          ),

          const SizedBox(height: 20),

          // Patient Details Section
          _buildSectionTitle("Patient Information"),
          _buildDetailItem(Icons.person_outline, "Name", patientName),
          _buildDetailItem(Icons.cake_outlined, "Age", patientAge),
          _buildDetailItem(Icons.transgender_outlined, "Gender", patientGender),

          const SizedBox(height: 20),

          // Notes/Problem Section
          _buildSectionTitle("Reason for Visit"),
          Text(
            notes,
            style: TextStyle(
                fontSize: 15,
                color: AppPallete.textColor.withOpacity(0.9),
                height: 1.4),
          ),
          const SizedBox(height: 30),

          if (_prescriptionPdfUrl != null &&
              _prescriptionPdfUrl!.isNotEmpty) ...[
            _buildSectionTitle("Prescription"),
            _buildPrescriptionButton(),
            const SizedBox(height: 20),
          ],

          // Action Buttons (Conditional)
          if (status.toLowerCase() == 'upcoming' &&
              paymentStatus.toLowerCase() == 'pending')
            _buildPayNowButton(),
          if (status.toLowerCase() == 'upcoming')
            _buildCancelButton(), // Example: Show cancel for upcoming
          if (status.toLowerCase() == 'completed')
            _buildReviewButton(), // Example: Show review for completed
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppPallete.primaryColor),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: AppPallete.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text("$label: ",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppPallete.textColor.withOpacity(0.8))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppPallete.textColor),
              textAlign: TextAlign.end, // Align value to the right
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.download_for_offline_outlined),
        label: const Text("View/Download Prescription"),
        onPressed: _launchPrescriptionUrl, // Call the launch function
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPallete.secondaryColor, // Use a distinct color
          foregroundColor: AppPallete.textColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildPayNowButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.payment),
          label: const Text("Pay Now"),
          onPressed: () {
            debugPrint(
                "Navigating to payment for Appointment ID: ${widget.appointmentId}");
            context.push('/payment', extra: widget.appointmentId);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.cancel_outlined),
          label: const Text("Cancel Appointment"),
          onPressed: () {
            context.push('/patient/appointment/history/cancel-form',
                extra: widget.appointmentId);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.rate_review_outlined),
          label: const Text("Add Review"),
          onPressed: () {
            // Extract necessary data for review page if needed
            final doctorData =
                _appointmentData!['doctor'] as Map<String, dynamic>?;
            final doctorName = _db.getDoctorDisplayName(doctorData);
            final specialty = doctorData?['specialty'] ?? 'N/A';
            final avatarUrl = _db.getDoctorAvatarUrl(doctorData);

            context.push('/patient/appointment/history/review2', extra: {
              'appointmentId': widget.appointmentId,
              'doctorName': doctorName,
              'specialty': specialty,
              'avatarUrl': avatarUrl,
              // Add any other data the review page requires
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallete.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.blue.shade700;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      default:
        return AppPallete.textColor;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade700;
      case 'success':
        return Colors.green.shade700;
      case 'failed':
        return Colors.red.shade700;
      case 'cancelled':
        return Colors.grey.shade700;
      default:
        return AppPallete.textColor;
    }
  }
}

// Removed redundant BottomNavBar class

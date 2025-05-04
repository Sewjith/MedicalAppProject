//@annotate:modification:lib/features/Patient/p_appointment_schedule/p_appointment_schedule.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/Patient/p_appointment_schedule/p_appointment_confirmation.dart';
import 'package:medical_app/features/Patient/p_appointment_schedule/p_appointment_schedule_db.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
// Removed unused import: import 'package:medical_app/core/errors/common/expection.dart';

class AppointmentSchedulePage extends StatefulWidget {
  final Map<String, dynamic>? doctorInfo;
  const AppointmentSchedulePage({super.key, this.doctorInfo});

  @override
  _AppointmentSchedulePageState createState() => _AppointmentSchedulePageState();
}

class _AppointmentSchedulePageState extends State<AppointmentSchedulePage> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  String? _selectedGender = "Female";
  String? _selectedDoctorId;
  String _selectedDoctorDisplay = "Select a Doctor";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Keep form key
  List<String> _availableTimes = [];
  List<Map<String, dynamic>> _availableDoctors = [];
  bool _isLoadingDoctors = true;
  bool _isLoadingTimes = false;
  bool _isPageLoading = true;

  final List<String> _allowedGenders = ['Male', 'Female', 'Other'];

  final DatabaseService _dbService = DatabaseService();
  String? _patientId;

  @override
  void initState() {
    super.initState();
    debugPrint("[initState] Received doctorInfo: ${widget.doctorInfo}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _initializeData();
    });
  }

  Future<void> _initializeData() async {
     if (!mounted) return;
     debugPrint("[_initializeData] Starting.");
     setState(() => _isPageLoading = true);

    // Get Patient Info
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserLoggedIn && userState.user.role == 'patient') {
       _patientId = userState.user.uid;
       _nameController.text = '${userState.user.firstname ?? ''} ${userState.user.lastname ?? ''}'.trim();
       final userGender = userState.user.gender;
       if (userGender != null && _allowedGenders.contains(userGender)) {
          _selectedGender = userGender;
       } else {
           // Keep the default or set a specific one if needed
           _selectedGender ??= "Female"; // Ensures it's not null
       }
       debugPrint("[_initializeData] Patient ID: $_patientId, Name: ${_nameController.text}, Gender: $_selectedGender");
    } else {
       _handleInitializationError('Error: Patient data unavailable.');
       return;
    }

    // Fetch Doctor List FIRST
    await _fetchDoctors(); // Fetch doctors for dropdown

    // Handle Pre-selection AFTER doctors are loaded
    if (widget.doctorInfo != null && !_isLoadingDoctors) {
       debugPrint("[_initializeData] Handling preselected doctor info...");
       final passedDoctorId = widget.doctorInfo!['doctorId'] as String?;
       final passedDoctorName = widget.doctorInfo!['doctorName'] as String?;

       if (passedDoctorId != null && _availableDoctors.any((doc) => doc['id'] == passedDoctorId)) {
           if (mounted) {
              setState(() {
                 _selectedDoctorId = passedDoctorId;
                 _selectedDoctorDisplay = passedDoctorName ?? 'Unknown Doctor';
              });
              debugPrint("[_initializeData] Preselected Doctor Set - ID: $_selectedDoctorId, Name: $_selectedDoctorDisplay");
              await _fetchAvailabilityForSelectedDoctor(); // Fetch availability for this doctor
           }
       } else {
           debugPrint("[_initializeData] Preselected doctor ID '$passedDoctorId' not found or info invalid.");
       }
    } else {
       debugPrint("[_initializeData] No doctor info passed or doctors still loading.");
    }

     if (mounted) {
       debugPrint("[_initializeData] Finished.");
       setState(() => _isPageLoading = false);
     }
  }

  // Helper for initialization errors
  void _handleInitializationError(String message) {
     debugPrint(message);
     if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(message), backgroundColor: Colors.red), );
        // Try to pop, otherwise navigate to dashboard
        WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted && context.canPop()) { context.pop(); }
           else if (mounted) { context.go('/p_dashboard'); }
        });
        setState(() { _isPageLoading = false; _isLoadingDoctors = false; _isLoadingTimes = false; });
     }
  }

  // Fetch list of doctors for the dropdown
  Future<void> _fetchDoctors() async {
     if (!mounted) return;
     // Avoid setting loading if already false (e.g., from error)
     if (!_isLoadingDoctors) setState(() => _isLoadingDoctors = true);

     try {
        final doctors = await _dbService.getAvailableDoctors();
        if (mounted) {
          setState(() {
             _availableDoctors = doctors;
             _isLoadingDoctors = false;
             // Reset selection if previously selected doctor is no longer available
             if (_selectedDoctorId != null && !_availableDoctors.any((doc) => doc['id'] == _selectedDoctorId)) {
                _selectedDoctorId = null;
                _selectedDoctorDisplay = "Select a Doctor";
                _availableTimes = [];
                _selectedTime = null;
             }
          });
        }
     } catch (e) {
        if (mounted) {
          setState(() => _isLoadingDoctors = false);
           // Show error fetching doctors
           ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Error fetching doctors: ${e.toString().replaceFirst("Exception: ","")}'), backgroundColor: Colors.red), );
        }
     }
  }

  // Fetch available time slots for the selected doctor and date
  Future<void> _fetchAvailabilityForSelectedDoctor() async {
    if (_selectedDoctorId == null || !mounted) return;
    setState(() { _isLoadingTimes = true; _availableTimes = []; _selectedTime = null; });
    try {
      final times = await _dbService.getDoctorAvailability(_selectedDoctorId!, _selectedDate);
       if (mounted) { setState(() { _availableTimes = times; _isLoadingTimes = false; }); }
    } catch (e) {
        if (mounted) {
           setState(() => _isLoadingTimes = false);
           ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Error fetching availability: ${e.toString().replaceFirst("Exception: ","")}'), backgroundColor: Colors.red), );
        }
    }
  }

  // Show Date Picker
  void _pickDate() async {
    DateTime? picked = await showDatePicker( context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)), );
    if (picked != null && picked != _selectedDate && mounted){
      setState(() { _selectedDate = picked; });
      if (_selectedDoctorId != null) { _fetchAvailabilityForSelectedDoctor(); } // Refresh times for new date
    }
  }

  // Proceed to Confirmation Page
  void _confirmAppointment() {
     if (!(_formKey.currentState?.validate() ?? false)) {
       _showValidationError("Please fill in all required fields correctly.");
       return;
     }
     if (_patientId == null) { _showValidationError('Error: Patient ID not found.'); return; }
     if (_selectedGender == null) { _showValidationError("Please select gender."); return; }
     if (_selectedDoctorId == null) { _showValidationError("Please select a doctor."); return; }
     if (_selectedTime == null) { _showValidationError("Please select an available time slot."); return; }

    final doctorDisplayName = _selectedDoctorDisplay; // Use the stored display name

    // Navigate to confirmation using push (not go) to keep schedule page in stack
    Navigator.push(
      context, MaterialPageRoute( builder: (context) => AppointmentConfirmationPage(
          name: _nameController.text.trim(), age: _ageController.text.trim(), gender: _selectedGender!,
          date: DateFormat('EEE, MMM dd, yyyy').format(_selectedDate), // Use yyyy for year
          time: _selectedTime!,
          doctor: doctorDisplayName, // Pass the display name
          problem: _problemController.text.trim().isEmpty ? "No description" : _problemController.text.trim(),
          // Pass the save function callback, including the doctor name
          onConfirm: () => _saveAppointment(doctorDisplayName),
      )),
    );
  }

  // Show validation error snackbar
  void _showValidationError(String message) {
     ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(message), backgroundColor: Colors.orange[800]), );
  }

  // Save appointment to DB - Now accepts doctorName for notification
  void _saveAppointment(String doctorNameForNotification) async {
     // Re-validate essential data just before saving
     if (_patientId == null || _selectedDoctorId == null || _selectedTime == null || _selectedGender == null) {
         _showValidationError("An unexpected error occurred. Missing required data.");
         return;
     }
     final patientName = _nameController.text.trim();
     final ageText = _ageController.text.trim();
     final patientAge = int.tryParse(ageText);

     if (patientName.isEmpty || patientAge == null || patientAge <= 0) {
         _showValidationError("Invalid patient details. Please check name and age.");
         return;
     }

     // Show loading indicator
     showDialog(
         context: context,
         barrierDismissible: false,
         builder: (context) => const Center(child: CircularProgressIndicator())
     );

     String? saveErrorMessage;

     try {
         // Pass doctorName to the booking function
         await _dbService.bookAppointment(
           patientId: _patientId!,
           doctorId: _selectedDoctorId!,
           problemDesc: _problemController.text.trim(),
           date: _selectedDate,
           time: _selectedTime!,
           patientName: patientName,
           patientAge: patientAge,
           patientGender: _selectedGender!,
           doctorName: doctorNameForNotification, // Pass name for notification
         );
         // Success case is handled in the confirmation dialog's OK button action

     } on Exception catch (e) {
         saveErrorMessage = e.toString().replaceFirst('Exception: ', '');
         debugPrint("[_saveAppointment] Save Error: $saveErrorMessage");
     } catch (e) {
        saveErrorMessage = "An unexpected error occurred during booking.";
        debugPrint("[_saveAppointment] Unexpected Save Error: $e");
     } finally {
         // Always dismiss the loading dialog
         if (mounted) {
            Navigator.pop(context); // Close loading dialog
         }
     }

     // Show error SnackBar *after* dialog is closed if an error occurred
     if (mounted && saveErrorMessage != null) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(saveErrorMessage), backgroundColor: Colors.red)
         );
         // Note: Navigation back happens in the confirmation dialog's OK button
     }
  }

  // Build Method
  @override
  Widget build(BuildContext context) {
     if (_isPageLoading) {
       return Scaffold(appBar: AppBar(title: const Text("Schedule Appointment")), body: const Center(child: CircularProgressIndicator()));
     }

    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        title: const Text("Schedule Appointment"),
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: AppPallete.whiteColor,
        elevation: 0,
         leading: BackButton(onPressed: () {
           if (context.canPop()) {
              context.pop();
           } else {
              context.go('/p_dashboard'); // Fallback if cannot pop
           }
         }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Use Form widget for validation
          child: Form(
            key: _formKey,
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Always show doctor selection dropdown
                    _doctorSelectionSection(),
                    const SizedBox(height: 16),

                    // Date/Time section enabled based on doctor selection
                    Opacity(
                       opacity: _selectedDoctorId == null ? 0.5 : 1.0,
                       child: IgnorePointer(
                         ignoring: _selectedDoctorId == null,
                         child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               _calendarSection(),
                               const SizedBox(height: 16),
                               _timeSelectionSection(),
                            ],
                         ),
                       ),
                    ),
                    const SizedBox(height: 16),
                    _userInfoForm(),
                    const SizedBox(height: 16),
                    _describeProblemSection(),
                    const SizedBox(height: 24),
                    _confirmButton(),
                  ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDER METHODS ---

  // Widget to show doctor selection dropdown
  Widget _doctorSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Doctor", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPallete.headings)),
        const SizedBox(height: 8),
        _isLoadingDoctors
            ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: CircularProgressIndicator(strokeWidth: 2)))
            : DropdownButtonFormField<String>(
                value: _selectedDoctorId,
                isExpanded: true,
                hint: const Text("Select a Doctor"),
                decoration: _inputDecoration(''), // Use helper, no label needed here
                onChanged: (String? newValue) {
                  if (newValue != null && mounted) {
                      setState(() {
                         _selectedDoctorId = newValue;
                         // Find selected doctor details to update display name
                         final selectedDoc = _availableDoctors.firstWhere((doc) => doc['id'] == newValue, orElse: () => {});
                         _selectedDoctorDisplay = selectedDoc.isNotEmpty ? '${selectedDoc['title'] ?? ''} ${selectedDoc['first_name'] ?? ''} ${selectedDoc['last_name'] ?? ''}'.trim() : 'Select a Doctor';
                         _fetchAvailabilityForSelectedDoctor(); // Fetch times for the new doctor
                      });
                  }
                },
                items: _availableDoctors.map<DropdownMenuItem<String>>( (Map<String, dynamic> doctor) {
                  String displayName = '${doctor['title'] ?? ''} ${doctor['first_name'] ?? ''} ${doctor['last_name'] ?? ''}'.trim();
                  String displaySpecialty = doctor['specialty'] ?? 'N/A';
                  return DropdownMenuItem<String>( value: doctor['id'], child: Text("$displayName ($displaySpecialty)", style: const TextStyle(color: AppPallete.textColor), overflow: TextOverflow.ellipsis), );
                }).toList(),
                validator: (value) => value == null ? 'Please select a doctor' : null, // Add validation
              ),
      ],
    );
  }

   Widget _calendarSection() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Select Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPallete.headings)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                 color: AppPallete.lightBackground, // Use light background
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: AppPallete.primaryColor.withOpacity(0.5)), // Subtle border
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Display full date format including weekday and year
                  Text(DateFormat('EEE, MMM dd, yyyy').format(_selectedDate), style: const TextStyle(fontSize: 16)),
                  const Icon(Icons.calendar_today, color: AppPallete.primaryColor),
                ],
              ),
            ),
          ),
        ],
      );
   }

   Widget _timeSelectionSection() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Available Time Slots", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPallete.headings)),
          const SizedBox(height: 8),
          _isLoadingTimes
              ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)))
              : _availableTimes.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                      child: const Center(
                        child: Text(
                          'No available slots for this doctor on the selected date.',
                          style: TextStyle(color: Colors.orange),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Wrap( // Use Wrap for better layout of chips
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTimes.map((time) {
                        bool isSelected = _selectedTime == time;
                        return ChoiceChip(
                          label: Text(time),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected && mounted) {
                              setState(() { _selectedTime = time; });
                            }
                          },
                          selectedColor: AppPallete.primaryColor,
                          labelStyle: TextStyle(color: isSelected ? AppPallete.whiteColor : AppPallete.textColor, fontWeight: FontWeight.bold),
                          backgroundColor: AppPallete.secondaryColor, // Use a consistent background
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: isSelected ? AppPallete.primaryColor : AppPallete.borderColor),
                          ),
                          showCheckmark: false, // Usually not needed for time slots
                        );
                      }).toList(),
                    ),
        ],
      );
   }

   Widget _userInfoForm() {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          const Text("Patient Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppPallete.headings)),
          const SizedBox(height: 12),
          _customTextField(_nameController, "Full Name*", isRequired: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                 child: _customTextField(_ageController, "Age*", keyboardType: TextInputType.number, isRequired: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                 child: DropdownButtonFormField<String>(
                   value: _selectedGender,
                   isExpanded: true,
                   decoration: _inputDecoration('Gender*'),
                   hint: const Text("Select Gender"),
                   items: _allowedGenders.map<DropdownMenuItem<String>>((String value) {
                     return DropdownMenuItem<String>( value: value, child: Text(value, style: const TextStyle(color: AppPallete.textColor)), );
                   }).toList(),
                    onChanged: (String? newValue) {
                       if (newValue != null && _allowedGenders.contains(newValue) && mounted) {
                          setState(() { _selectedGender = newValue; });
                       }
                    },
                   validator: (value) => value == null ? 'Please select gender' : null,
                 ),
              ),
            ],
          ),
       ],
     );
   }

   Widget _describeProblemSection() {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          const Text("Describe Your Problem (Optional)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPallete.headings)),
          const SizedBox(height: 8),
          TextField( // Use TextField for optional field, no validator needed
             controller: _problemController,
             maxLines: 4,
             maxLength: 300, // Limit length
             decoration: _inputDecoration("Enter details here...").copyWith(labelText: null), // Remove label, keep hint
          ),
       ],
     );
   }

   Widget _confirmButton() {
     // Button is enabled only when essential selections are made
     final bool canConfirm = _selectedDoctorId != null && _selectedTime != null && _patientId != null && _formKey.currentState?.validate() == true;
     return SizedBox(
       width: double.infinity,
       child: ElevatedButton(
         onPressed: canConfirm ? _confirmAppointment : null, // Disable if cannot confirm
         style: ElevatedButton.styleFrom(
           backgroundColor: AppPallete.primaryColor,
           foregroundColor: AppPallete.whiteColor,
           disabledBackgroundColor: AppPallete.greyColor.withOpacity(0.5), // Grey out when disabled
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
           padding: const EdgeInsets.symmetric(vertical: 14),
         ),
         child: const Text("Proceed to Confirmation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
       ),
     );
   }

   // Helper for TextFormFields with consistent styling and validation
   Widget _customTextField(
      TextEditingController controller,
      String label, {
      TextInputType keyboardType = TextInputType.text,
      bool isRequired = false,
   }) {
      return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(label),
        validator: isRequired ? (value) {
          if (value == null || value.trim().isEmpty) {
             return 'Please enter ${label.replaceAll("*", "").trim()}';
          }
          // Specific validation for age
          if (label.toLowerCase().contains('age')) {
             final age = int.tryParse(value.trim());
             if (age == null || age <= 0) {
                return 'Please enter a valid age';
             }
          }
          return null;
        } : null,
        autovalidateMode: AutovalidateMode.onUserInteraction, // Validate as user types
      );
   }

   // Helper for InputDecoration styling
   InputDecoration _inputDecoration(String label) {
      String displayLabel = label.endsWith('*') ? label.substring(0, label.length - 1).trim() : label;
      return InputDecoration(
        labelText: displayLabel.isNotEmpty ? displayLabel : null, // Show label if provided
        hintText: displayLabel.isNotEmpty ? null : 'Select...', // Show hint if no label
        labelStyle: const TextStyle(color: AppPallete.greyColor), // Style for label
        hintStyle: TextStyle(color: AppPallete.greyColor.withOpacity(0.7)), // Style for hint
        filled: true,
        fillColor: AppPallete.lightBackground, // Background color
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppPallete.borderColor)), // Base border
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppPallete.borderColor)), // Enabled state border
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppPallete.primaryColor, width: 1.5)), // Focused state border
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)), // Error state border
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1.5)), // Focused error border
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Padding inside the field
      );
   }

}
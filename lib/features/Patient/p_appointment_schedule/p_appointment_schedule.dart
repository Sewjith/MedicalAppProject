import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/Patient/p_appointment_schedule/p_appointment_confirmation.dart';
import 'package:medical_app/features/Patient/p_appointment_schedule/p_appointment_schedule_db.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/errors/common/expection.dart';

class AppointmentSchedulePage extends StatefulWidget {
  // doctorInfo map is optional: {'doctorId': '...', 'doctorName': '...'}
  final Map<String, dynamic>? doctorInfo;
  const AppointmentSchedulePage({super.key, this.doctorInfo});

  @override
  _AppointmentSchedulePageState createState() => _AppointmentSchedulePageState();
}

class _AppointmentSchedulePageState extends State<AppointmentSchedulePage> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  String? _selectedGender = "Female"; // Keep default or fetch
  String? _selectedDoctorId; // Can be null initially or set by doctorInfo
  String _selectedDoctorDisplay = "Select a Doctor"; // Used for display if ID is set

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> _availableTimes = [];
  // Restore state for the full doctor list
  List<Map<String, dynamic>> _availableDoctors = [];
  // Restore loading state for the doctor list
  bool _isLoadingDoctors = true;
  bool _isLoadingTimes = false;
  bool _isPageLoading = true;

  final List<String> _allowedGenders = ['Male', 'Female', 'Other'];
  // Flag is less critical now, but can still be used for initial check
  // bool _isDoctorPreselected = false;

  final DatabaseService _dbService = DatabaseService();
  String? _patientId;

  @override
  void initState() {
    super.initState();
    // _isDoctorPreselected = widget.doctorInfo != null; // Can still set this if useful elsewhere
    debugPrint("[initState] Received doctorInfo: ${widget.doctorInfo}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _initializeData();
    });
  }

  Future<void> _initializeData() async {
     if (!mounted) return;
     debugPrint("[_initializeData] Starting.");
     setState(() => _isPageLoading = true);

    // --- Get Patient Info (Same as before) ---
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserLoggedIn && userState.user.role == 'patient') {
       _patientId = userState.user.uid;
       _nameController.text = '${userState.user.firstname ?? ''} ${userState.user.lastname ?? ''}'.trim();
       final userGender = userState.user.gender;
       if (userGender != null && _allowedGenders.contains(userGender)) { _selectedGender = userGender; }
       else { _selectedGender ??= "Female"; }
    } else {
       _handleInitializationError('Error: Patient data unavailable.');
       return;
    }
    // --- End Get Patient Info ---

    // --- Fetch Doctor List FIRST ---
    await _fetchDoctors(); // Always fetch the list for the dropdown

    // --- Handle Pre-selection AFTER doctors are loaded ---
    if (widget.doctorInfo != null && !_isLoadingDoctors) { // Ensure doctors are loaded
       debugPrint("[_initializeData] Handling preselected doctor info...");
       final passedDoctorId = widget.doctorInfo!['doctorId'] as String?;
       final passedDoctorName = widget.doctorInfo!['doctorName'] as String?;

       // Check if the passed doctor ID exists in the fetched list
       if (passedDoctorId != null && _availableDoctors.any((doc) => doc['id'] == passedDoctorId)) {
           // Set the state to pre-select the doctor in the dropdown
           if (mounted) {
              setState(() {
                 _selectedDoctorId = passedDoctorId;
                 _selectedDoctorDisplay = passedDoctorName ?? 'Unknown Doctor'; // Set display name too
              });
              debugPrint("[_initializeData] Preselected Doctor Set - ID: $_selectedDoctorId, Name: $_selectedDoctorDisplay");
              // Fetch availability for the pre-selected doctor
              await _fetchAvailabilityForSelectedDoctor();
           }
       } else {
           debugPrint("[_initializeData] Preselected doctor ID '$passedDoctorId' not found in fetched list or info invalid.");
           // Do not set _selectedDoctorId, let the user choose from dropdown
       }
    } else {
       debugPrint("[_initializeData] No doctor info passed or doctors still loading. Dropdown will be shown.");
    }
    // --- End Handle Pre-selection ---

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
        WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted && context.canPop()) { context.pop(); } else if (mounted) { context.go('/p_dashboard');} });
        setState(() { _isPageLoading = false; _isLoadingDoctors = false; _isLoadingTimes = false; });
     }
  }

  // Restored: Fetch list of doctors for the dropdown
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
            // Check if the current selection is still valid after refresh
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
    } catch (e) { if (mounted) { setState(() => _isLoadingTimes = false); ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Error fetching availability: ${e.toString().replaceFirst("Exception: ","")}'), backgroundColor: Colors.red), ); } }
  }

  // Show Date Picker
  void _pickDate() async {
    DateTime? picked = await showDatePicker( context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)), );
    if (picked != null && picked != _selectedDate && mounted){
      setState(() { _selectedDate = picked; });
      if (_selectedDoctorId != null) { _fetchAvailabilityForSelectedDoctor(); }
    }
  }

  // Proceed to Confirmation Page
  void _confirmAppointment() {
     if (_patientId == null) { _showValidationError('Error: Patient ID not found.'); return; }
     if (_nameController.text.trim().isEmpty) { _showValidationError("Please enter name."); return; }
     if (_ageController.text.trim().isEmpty) { _showValidationError("Please enter age."); return; }
     if (int.tryParse(_ageController.text.trim()) == null) { _showValidationError("Invalid age."); return; }
     if (_selectedGender == null) { _showValidationError("Please select gender."); return; }
     if (_selectedDoctorId == null) { _showValidationError("Please select doctor."); return; } // Validation still important
     if (_selectedTime == null) { _showValidationError("Please select time."); return; }

    final doctorDisplayName = _selectedDoctorDisplay ?? 'Unknown Doctor'; // Use the display name

    Navigator.push(
      context, MaterialPageRoute( builder: (context) => AppointmentConfirmationPage(
          name: _nameController.text.trim(), age: _ageController.text.trim(), gender: _selectedGender!,
          date: DateFormat('EEE, MMM dd, EEEE').format(_selectedDate), time: _selectedTime!,
          doctor: doctorDisplayName, problem: _problemController.text.trim().isEmpty ? "No description" : _problemController.text.trim(),
          onConfirm: _saveAppointment,
      )),
    );
  }

  // Show validation error snackbar
  void _showValidationError(String message) {
     ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(message), backgroundColor: Colors.orange[800]), );
  }

  // Save appointment to DB
  void _saveAppointment() async {
     // Re-validate before saving
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

     String? saveErrorMessage; // Variable to store error message

     try {
         await _dbService.bookAppointment(
           patientId: _patientId!,
           doctorId: _selectedDoctorId!,
           problemDesc: _problemController.text.trim(),
           date: _selectedDate,
           time: _selectedTime!,
           patientName: patientName,
           patientAge: patientAge,
           patientGender: _selectedGender!,
         );
         // Success case is handled in the confirmation dialog's OK button action
         // No need to do anything here on success other than closing the dialog later

     } on Exception catch (e) { // Catch the specific exception
         saveErrorMessage = e.toString().replaceFirst('Exception: ', '');
         debugPrint("[_saveAppointment] Save Error: $saveErrorMessage");
     } catch (e) { // Catch any other unexpected errors
        saveErrorMessage = "An unexpected error occurred during booking.";
        debugPrint("[_saveAppointment] Unexpected Save Error: $e");
     } finally {
         // *** IMPORTANT: Always dismiss the loading dialog ***
         if (mounted) {
            Navigator.pop(context); // Close loading dialog
         }
     }

     // --- Show error SnackBar *after* dialog is closed if an error occurred ---
     if (mounted && saveErrorMessage != null) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(saveErrorMessage), backgroundColor: Colors.red)
         );
         // NOTE: We don't navigate back here automatically on error.
         // The user is still on the confirmation screen and can press Cancel or retry.
         // The `onConfirm` callback passed to ConfirmationPage calls this `_saveAppointment`.
         // The actual navigation back happens when the success dialog's "OK" button is pressed.
     }
  }

  // Build Method - Renders dropdown section always now
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
             child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Always render the doctor selection section (dropdown)
                  _doctorSelectionSection(),
                  const SizedBox(height: 16),

                  // Date/Time section enabled based on _selectedDoctorId
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
    );
  }

  // --- WIDGET BUILDER METHODS ---

  // Removed _buildPreselectedDoctorInfo

  // Restored: Widget to show dropdown
  Widget _doctorSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Doctor", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPallete.headings)),
        const SizedBox(height: 8),
        _isLoadingDoctors
            ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: CircularProgressIndicator(strokeWidth: 2)))
            : DropdownButtonFormField<String>(
                value: _selectedDoctorId, // This will now be pre-filled if doctorInfo was passed and valid
                isExpanded: true,
                hint: const Text("Select a Doctor"), // Hint shown if _selectedDoctorId is null
                decoration: _inputDecoration(''), // Use helper
                onChanged: (String? newValue) {
                  if (newValue != null && mounted) {
                      setState(() {
                         _selectedDoctorId = newValue;
                         final selectedDoc = _availableDoctors.firstWhere((doc) => doc['id'] == newValue, orElse: () => {});
                         // Update display name for confirmation page
                         _selectedDoctorDisplay = selectedDoc.isNotEmpty ? '${selectedDoc['title'] ?? ''} ${selectedDoc['first_name'] ?? ''} ${selectedDoc['last_name'] ?? ''}'.trim() : 'Select a Doctor';
                         _fetchAvailabilityForSelectedDoctor(); // Fetch times for newly selected doctor
                      });
                  }
                },
                items: _availableDoctors.map<DropdownMenuItem<String>>( (Map<String, dynamic> doctor) {
                  String displayName = '${doctor['title'] ?? ''} ${doctor['first_name'] ?? ''} ${doctor['last_name'] ?? ''}'.trim();
                  String displaySpecialty = doctor['specialty'] ?? 'N/A';
                  return DropdownMenuItem<String>( value: doctor['id'], child: Text("$displayName ($displaySpecialty)", style: const TextStyle(color: AppPallete.textColor), overflow: TextOverflow.ellipsis), );
                }).toList(),
                validator: (value) => value == null ? 'Please select a doctor' : null,
              ),
      ],
    );
  }

  // --- (Keep other build methods: _calendarSection, _timeSelectionSection, _userInfoForm, etc.) ---
   Widget _calendarSection() { return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text("Select Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPallete.headings)), const SizedBox(height: 8), GestureDetector( onTap: _pickDate, child: Container( padding: const EdgeInsets.all(12), decoration: BoxDecoration( color: AppPallete.lightBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppPallete.primaryColor.withOpacity(0.5)), ), child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text(DateFormat('EEE, MMM dd, EEEE').format(_selectedDate), style: const TextStyle(fontSize: 16)), const Icon(Icons.calendar_today, color: AppPallete.primaryColor), ], ), ), ), ], ); }
   Widget _timeSelectionSection() { return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text("Available Time Slots", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPallete.headings)), const SizedBox(height: 8), _isLoadingTimes ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2))) : _availableTimes.isEmpty ? Container( padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('No available slots for this doctor on the selected date.', style: TextStyle(color: Colors.orange), textAlign: TextAlign.center,)) ) : Wrap( spacing: 8, runSpacing: 8, children: _availableTimes.map((time) { bool isSelected = _selectedTime == time; return ChoiceChip( label: Text(time), selected: isSelected, onSelected: (selected) { if (selected && mounted) { setState(() { _selectedTime = time; }); } }, selectedColor: AppPallete.primaryColor, labelStyle: TextStyle(color: isSelected ? AppPallete.whiteColor : AppPallete.textColor, fontWeight: FontWeight.bold), backgroundColor: AppPallete.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppPallete.primaryColor : AppPallete.borderColor)), showCheckmark: false, ); }).toList(), ), ], ); }
   Widget _userInfoForm() { return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text("Patient Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppPallete.headings)), const SizedBox(height: 12), _customTextField(_nameController, "Full Name*", isRequired: true), const SizedBox(height: 12), Row( children: [ Expanded( child: _customTextField(_ageController, "Age*", keyboardType: TextInputType.number, isRequired: true), ), const SizedBox(width: 12), Expanded( child: DropdownButtonFormField<String>( value: _selectedGender, isExpanded: true, decoration: _inputDecoration('Gender*'), hint: const Text("Select Gender"), onChanged: (String? newValue) { if (newValue != null && _allowedGenders.contains(newValue) && mounted) { setState(() { _selectedGender = newValue; }); } }, items: _allowedGenders.map<DropdownMenuItem<String>>((String value) { return DropdownMenuItem<String>( value: value, child: Text(value, style: const TextStyle(color: AppPallete.textColor)), ); }).toList(), validator: (value) => value == null ? 'Please select gender' : null, ), ), ], ), const SizedBox(height: 12), ], ); }
   Widget _describeProblemSection() { return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ const Text("Describe Your Problem (Optional)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPallete.headings)), const SizedBox(height: 8), TextField( controller: _problemController, maxLines: 4, maxLength: 300, decoration: _inputDecoration("Enter details here...").copyWith(labelText: null), ), ], ); }
   Widget _confirmButton() { final bool canConfirm = _selectedDoctorId != null && _selectedTime != null && _patientId != null; return SizedBox( width: double.infinity, child: ElevatedButton( onPressed: canConfirm ? _confirmAppointment : null, style: ElevatedButton.styleFrom( backgroundColor: AppPallete.primaryColor, foregroundColor: AppPallete.whiteColor, disabledBackgroundColor: AppPallete.greyColor.withOpacity(0.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14), ), child: const Text("Proceed to Confirmation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), ), ); }
   Widget _customTextField( TextEditingController controller, String label, { TextInputType keyboardType = TextInputType.text, bool isRequired = false, }) { return TextFormField( controller: controller, keyboardType: keyboardType, decoration: _inputDecoration(label), validator: isRequired ? (value) { if (value == null || value.trim().isEmpty) { return 'Please enter ${label.replaceAll("*", "").trim()}'; } if (label.toLowerCase().contains('age') && int.tryParse(value.trim()) == null) { return 'Please enter a valid age'; } return null; } : null, autovalidateMode: AutovalidateMode.onUserInteraction, ); }
   InputDecoration _inputDecoration(String label) { String displayLabel = label.endsWith('*') ? label.substring(0, label.length - 1).trim() : label; return InputDecoration( labelText: displayLabel.isNotEmpty ? displayLabel : null, hintText: displayLabel.isNotEmpty ? null : 'Select...', labelStyle: TextStyle(color: AppPallete.greyColor), hintStyle: TextStyle(color: AppPallete.greyColor.withOpacity(0.7)), filled: true, fillColor: AppPallete.lightBackground, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppPallete.borderColor)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppPallete.borderColor)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppPallete.primaryColor, width: 1.5)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)), focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), ); }

} 
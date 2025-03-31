import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/in-app-payments/home.dart';
import 'package:medical_app/features/p_appointment_schedule/p_appointment_confirmation.dart';
import 'package:medical_app/features/p_appointment_schedule/p_appointment_schedule_db.dart';

class AppointmentSchedulePage extends StatefulWidget {
  const AppointmentSchedulePage({super.key});

  @override
  _AppointmentSchedulePageState createState() =>
      _AppointmentSchedulePageState();
}

class _AppointmentSchedulePageState extends State<AppointmentSchedulePage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = "10:00 AM";
  String _selectedGender = "Female";
  String _selectedDoctor = "Dr. A"; // Default doctor
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();

  final List<String> availableTimes = [
    "9:00 AM", "9:15 AM","9:30 AM","9:45 AM","10:00 AM","10:15 AM","10:30 AM","10:45 AM","11:00 AM","11:15 AM","11:30 AM","11:45 AM","12:00 PM","12:15 PM","12:30 PM",
    "12:45 PM","1:00 PM","1:15 PM","1:30 PM","1:45 PM","2:00 PM","2:15 PM","2:30 PM","2:45 PM","3:00 PM","3:15 PM","3:30 PM","3:45 PM","4:00 PM",
  ];

  final List<Map<String, String>> doctors = [
    {"name": "Dr. A", "category": "General Physician"},
    {"name": "Dr. B", "category": "Pediatrician"},
    {"name": "Dr. C", "category": "Cardiologist"},
  ];

  final DatabaseService _dbService = DatabaseService();

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    setState(() {
      _selectedDate = picked!;
    });
    }

  void _confirmAppointment() {
    if (_nameController.text.isEmpty || _ageController.text.isEmpty || _problemController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in all the required fields."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (int.tryParse(_ageController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid age."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentConfirmationPage(
          name: _nameController.text,
          age: _ageController.text,
          gender: _selectedGender,
          date: _selectedDate.toString(),
          time: _selectedTime,
          doctor: _selectedDoctor,
          problem: _problemController.text.isEmpty ? "No description" : _problemController.text,
          onConfirm: () {
            _saveAppointment();
          },
        ),
      ),
    );
  }

  void _saveAppointment() async {
  bool success = await _dbService.bookAppointment(
    name: _nameController.text,
    age: int.tryParse(_ageController.text) ?? 0,
    gender: _selectedGender,
    problemDesc: _problemController.text.isEmpty ? "No description" : _problemController.text,
    date: _selectedDate,
    time: _selectedTime,
    doctor: _selectedDoctor,
  );

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Appointment confirmed! Redirecting to payment..."),
        backgroundColor: Colors.green,
      ),
    );

    // Redirect to PaymentHomePage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentHomePage(),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to confirm appointment. Please try again."),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
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
              _calendarSection(),
              const SizedBox(height: 16),
              _timeSelectionSection(),
              const SizedBox(height: 16),
              _doctorSelectionSection(),
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

  Widget _calendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Date",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppPallete.headings,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppPallete.lightBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppPallete.primaryColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_selectedDate.toLocal()}".split(' ')[0],
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: AppPallete.primaryColor,
                ),
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
        const Text(
          "Available Time",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppPallete.headings,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              availableTimes.map((time) {
                bool isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = time;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppPallete.primaryColor
                              : AppPallete.secondaryColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppPallete.primaryColor,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isSelected
                                ? AppPallete.whiteColor
                                : AppPallete.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _doctorSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Doctor",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppPallete.headings,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _selectedDoctor,
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              _selectedDoctor = newValue!;
            });
          },
          items:
              doctors.map<DropdownMenuItem<String>>((
                Map<String, String> doctor,
              ) {
                return DropdownMenuItem<String>(
                  value: doctor["name"],
                  child: Text(
                    "${doctor['name']} (${doctor['category']})",
                    style: const TextStyle(color: AppPallete.textColor),
                  ),
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
        const Text(
          "Full Name",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppPallete.headings,
          ),
        ),
        _customTextField(_nameController, "Enter your name"),
        const SizedBox(height: 12),
        const Text(
          "Age",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppPallete.headings,
          ),
        ),
        _customTextField(
          _ageController,
          "Enter your age",
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        const Text(
          "Gender",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppPallete.headings,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _selectedGender,
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue!;
            });
          },
          items:
              <String>['Male', 'Female', 'Other'].map<DropdownMenuItem<String>>(
                (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: AppPallete.textColor),
                    ),
                  );
                },
              ).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _describeProblemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Describe Your Problem",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppPallete.headings,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _problemController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Enter your problem...",
            filled: true,
            fillColor: AppPallete.secondaryColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _confirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _confirmAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPallete.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          "Confirm Appointment",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _customTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppPallete.secondaryColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
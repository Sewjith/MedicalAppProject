import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/patient/patient_profile/pages/settings.dart';
import 'package:medical_app/features/patient/patient_profile/patient_db.dart';

class PatientEditProfilePage extends StatefulWidget {
  final Map<String, dynamic> patientData;
  final VoidCallback onProfileUpdated;

  const PatientEditProfilePage({
    Key? key,
    required this.patientData,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  _PatientEditProfilePageState createState() => _PatientEditProfilePageState();
}

class _PatientEditProfilePageState extends State<PatientEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final PatientDB _patientDB = PatientDB();
  final ImagePicker _picker = ImagePicker();
  final String patientId = "patient-id-here"; // Replace with actual patient ID

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _emailController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _genderController;
  late final TextEditingController _addressController;
  late final TextEditingController _ageController;

  File? _selectedImage;
  String? _avatarPath;
  String? _avatarUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _avatarPath = widget.patientData['avatar_path'];
    _avatarUrl = widget.patientData['avatar_url'];
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController(text: widget.patientData['first_name']?.toString() ?? '');
    _lastNameController = TextEditingController(text: widget.patientData['last_name']?.toString() ?? '');
    _phoneNumberController = TextEditingController(text: widget.patientData['phone_number']?.toString() ?? '');
    _emailController = TextEditingController(text: widget.patientData['email']?.toString() ?? '');
    _dateOfBirthController = TextEditingController(text: widget.patientData['date_of_birth']?.toString() ?? '');
    _genderController = TextEditingController(text: widget.patientData['gender']?.toString() ?? '');
    _addressController = TextEditingController(text: widget.patientData['address']?.toString() ?? '');
    _ageController = TextEditingController(text: widget.patientData['age']?.toString() ?? '0');
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _isUploading = true;
      });

      final path = await _patientDB.uploadAvatar(patientId, image.path);

      setState(() {
        _avatarPath = path;
        _isUploading = false;
      });

    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: ${e.toString()}'),
          backgroundColor: AppPallete.errorColor,
        ),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _patientDB.updatePatientProfile(
          patientId: patientId,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phoneNumber: _phoneNumberController.text,
          email: _emailController.text,
          dateOfBirth: _dateOfBirthController.text,
          gender: _genderController.text,
          address: _addressController.text,
          age: int.tryParse(_ageController.text) ?? 0,
          avatarPath: _avatarPath,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        widget.onProfileUpdated();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppPallete.errorColor,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : (_selectedImage == null && _avatarUrl == null)
                  ? Icon(
                Icons.person,
                size: 60,
                color: Colors.grey[600],
              )
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppPallete.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                onPressed: _pickImage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        backgroundColor: AppPallete.whiteColor,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: AppPallete.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 35,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppPallete.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppPallete.primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PatientSettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 20),
              _buildTextField('First Name', _firstNameController),
              _buildTextField('Last Name', _lastNameController),
              _buildTextField('Phone Number', _phoneNumberController),
              _buildTextField('Email', _emailController),
              _buildTextField('Date of Birth (YYYY-MM-DD)', _dateOfBirthController),
              _buildTextField('Gender', _genderController),
              _buildTextField('Address', _addressController, maxLines: 3),
              _buildTextField('Age', _ageController, isNumber: true),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppPallete.whiteColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        bool isNumber = false,
        int maxLines = 1,
        String? hintText,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.all(16.0),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (isNumber && int.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}
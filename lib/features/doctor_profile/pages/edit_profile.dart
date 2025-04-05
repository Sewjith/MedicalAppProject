import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor_profile/pages/settings.dart';
import 'package:medical_app/features/doctor_profile/profile_db.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> doctorData;
  final VoidCallback onProfileUpdated;

  const EditProfilePage({
    Key? key,
    required this.doctorData,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ProfileDB _profileDB = ProfileDB();
  final ImagePicker _picker = ImagePicker();
  final String doctorId = "79ee85c5-c5da-41f5-b4a0-579f4792f32f";

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _titleController;
  late final TextEditingController _specialtyController;
  late final TextEditingController _yearsOfExperienceController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _emailController;
  late final TextEditingController _qualificationsController;
  late final TextEditingController _genderController;
  late final TextEditingController _amountController;
  late final TextEditingController _languageController;

  File? _selectedImage;
  String? _avatarPath;
  String? _avatarUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _avatarPath = widget.doctorData['avatar_path'];
    _avatarUrl = widget.doctorData['avatar_url'];
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController(text: widget.doctorData['first_name']?.toString() ?? '');
    _lastNameController = TextEditingController(text: widget.doctorData['last_name']?.toString() ?? '');
    _titleController = TextEditingController(text: widget.doctorData['title']?.toString() ?? 'Dr.');
    _specialtyController = TextEditingController(text: widget.doctorData['specialty']?.toString() ?? '');
    _yearsOfExperienceController = TextEditingController(
        text: widget.doctorData['years_of_experience']?.toString() ?? '0');
    _phoneNumberController = TextEditingController(text: widget.doctorData['phone_number']?.toString() ?? '');
    _emailController = TextEditingController(text: widget.doctorData['email']?.toString() ?? '');
    _qualificationsController = TextEditingController(
        text: (widget.doctorData['qualifications'] != null)
            ? (widget.doctorData['qualifications'] as List).join(', ')
            : '');
    _genderController = TextEditingController(text: widget.doctorData['gender']?.toString() ?? '');
    _amountController = TextEditingController(
        text: widget.doctorData['amount']?.toString() ?? '0.0');
    _languageController = TextEditingController(
        text: (widget.doctorData['language'] != null)
            ? (widget.doctorData['language'] as List).join(', ')
            : '');
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _isUploading = true;
      });

      final path = await _profileDB.uploadAvatar(doctorId, image.path);

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
        String qualificationsArrayLiteral = '{${_qualificationsController.text.split(',').map((e) => e.trim()).join(',')}}';
        String languageArrayLiteral = '{${_languageController.text.split(',').map((e) => e.trim()).join(',')}}';

        await _profileDB.updateDoctorProfile(
          doctorId: doctorId,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          title: _titleController.text,
          specialty: _specialtyController.text,
          yearsOfExperience: int.tryParse(_yearsOfExperienceController.text) ?? 0,
          phoneNumber: _phoneNumberController.text,
          email: _emailController.text,
          qualifications: qualificationsArrayLiteral,
          gender: _genderController.text,
          amount: double.tryParse(_amountController.text) ?? 0.0,
          language: languageArrayLiteral,
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
    _titleController.dispose();
    _specialtyController.dispose();
    _yearsOfExperienceController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _qualificationsController.dispose();
    _genderController.dispose();
    _amountController.dispose();
    _languageController.dispose();
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
                MaterialPageRoute(builder: (context) => const settings()),
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
              _buildTextField('Title (Dr., Prof., etc.)', _titleController),
              _buildTextField('Specialty', _specialtyController),
              _buildTextField('Years of Experience', _yearsOfExperienceController, isNumber: true),
              _buildTextField('Phone Number', _phoneNumberController),
              _buildTextField('Email', _emailController),
              _buildTextField('Qualifications', _qualificationsController, maxLines: 3),
              _buildTextField('Gender', _genderController),
              _buildTextField('Consultation Fee', _amountController, isNumber: true),
              _buildTextField(
                'Languages Spoken',
                _languageController,
                hintText: 'Example: English, Spanish, French',
              ),
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
          if (isNumber && double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}
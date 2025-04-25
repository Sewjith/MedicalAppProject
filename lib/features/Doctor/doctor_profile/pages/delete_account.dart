import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor/doctor_profile/pages/delete_account_db.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medical_app/features/auth/presentation/screens/login_page.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final DeleteAccountDB _deleteAccountDB = DeleteAccountDB();
  final TextEditingController _passwordController = TextEditingController();
  final String doctorId = "DOC001";
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _archiveAccount() async {
    if (_passwordController.text.isEmpty) {
      _showErrorSnackbar("Please enter your password");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _deleteAccountDB.archiveDoctorAccount(
        doctorId: doctorId,
        inputPassword: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deactivated successfully!'),
          ),
        );
      }

      await Supabase.instance.client.auth.signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppPallete.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppPallete.errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Deletion',
          style: TextStyle(color: AppPallete.textColor),
        ),
        content: Text(
          'This will permanently delete your account. Continue?',
          style: TextStyle(color: AppPallete.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppPallete.primaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _archiveAccount();
            },
            child: _isLoading
                ? CircularProgressIndicator(color: AppPallete.errorColor)
                : Text(
              'Delete',
              style: TextStyle(color: AppPallete.errorColor),
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
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppPallete.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Delete Account',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: AppPallete.headings,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Warning:",
              style: TextStyle(
                fontSize: 18,
                color: AppPallete.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Deleting your account will permanently erase all your data, including settings, preferences, and history. This action cannot be undone. If you are sure about this, please enter your password below.",
              style: TextStyle(
                fontSize: 16,
                color: AppPallete.textColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Enter Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppPallete.textColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blue[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppPallete.textColor.withOpacity(0.6),
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.errorColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 15,
                  ),
                ),
                onPressed: _isLoading ? null : _showConfirmationDialog,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: 20,
                    color: AppPallete.whiteColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor_profile/pages/settings.dart';

void main(){
  runApp(const deleteAccount());
}
class deleteAccount extends StatelessWidget{
  const deleteAccount({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: delete(),
    );
  }
}
class delete extends StatefulWidget {
  @override
  _deleteState createState() => _deleteState();
}

class _deleteState extends State<delete> {
  bool password = true;

  void _showDeleteConfirmation() {
    showDialog(context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Deletion',
            style: TextStyle(color: AppPallete.textColor),),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(color: AppPallete.textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                style: TextStyle(color: AppPallete.textColor),),
            ),
            TextButton(onPressed: () {
              Navigator.pop(context);
            }, child: Text('Delete',
                style: TextStyle(color: AppPallete.errorColor)),
            ),
          ],
        );
      },
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
          icon: Icon(
              Icons.arrow_back_ios_new_sharp, color: AppPallete.primaryColor),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => setting()));
          },
        ),
        title: Text(
          'Delete Account',
          style: TextStyle(
              fontSize: 35,
              color: AppPallete.headings,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Warning:",
              style: TextStyle(fontSize: 17,
                  color: AppPallete.errorColor,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "Deleting your account will permanently erase all your data, including settings, preferences, and history. This action cannot be undone. If you are sure about this, please enter your password below.",
              style: TextStyle(fontSize: 16, color: AppPallete.textColor),
              textAlign: TextAlign.justify,
              softWrap: true,
            ),
            SizedBox(height: 20),
            Text(
              'Enter Password',
              style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.textColor),
            ),
            SizedBox(height: 14),
            TextField(
              obscureText: password,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blue[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(password ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      password = !password;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(child: Container()),
            Center(
              child: SizedBox(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.errorColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  onPressed: _showDeleteConfirmation,
                  child: Text('Delete Account',
                    style: TextStyle(
                        fontSize: 21, color: AppPallete.secondaryColor),
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
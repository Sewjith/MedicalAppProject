import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor_profile/pages/settings.dart';

void main(){
  runApp(const password());
}
class password extends StatelessWidget{
  const password({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: passwords(),
    );
  }
}
class passwords extends StatefulWidget{
  @override
  passwordsState createState() => passwordsState();
}

class passwordsState extends State<passwords> {
  bool currentPassword = true;
  bool newPassword = true;
  bool confirmPassword = true;

  void passwordChangeConfirmation(BuildContext context){
    showDialog(context: context,
        builder: (BuildContext context)
        {
          return AlertDialog(
              content: Text(
                'Password change successful',
                style: TextStyle(color: AppPallete.textColor, fontSize: 15),),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Ok',
                    style: TextStyle(color: AppPallete.primaryColor),),
                ),
              ]
          );
        }
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
          icon: Icon(Icons.arrow_back_ios_new_sharp, color: AppPallete.primaryColor),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => setting()));
          },
        ),
        title: Text(
          'Password Manager',
          style: TextStyle(
              fontSize: 35, color: AppPallete.headings, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(padding:
      const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildPasswordField('Current Password', currentPassword, () {
                      setState(() {
                        currentPassword = !currentPassword;
                      });
                    }),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: () {

                      }, child: Text(
                        'Forgot Password',
                        style: TextStyle(color: AppPallete.primaryColor),
                      ),
                      ),
                    ),
                    buildPasswordField('New Password', newPassword, () {
                      setState(() {
                        newPassword = !newPassword;
                      });
                    }),
                    buildPasswordField('Confirm New Password', confirmPassword, () {
                      setState(() {
                        confirmPassword = !confirmPassword;
                      });
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: () {
                    passwordChangeConfirmation(context);
                  },
                  child: Text('Change Password',
                    style: TextStyle(fontSize: 20, color: AppPallete.secondaryColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget buildPasswordField(String label, bool text, VoidCallback visibility) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPallete.textColor),),
        SizedBox(height: 8),
        TextField(
          obscureText: text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.blue[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(text ? Icons.visibility_off : Icons.visibility,color: AppPallete.textColor,
              ),
              onPressed: visibility,
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}


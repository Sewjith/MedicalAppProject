import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';

void main(){
  runApp(TermsPage());
}
class TermsPage extends StatelessWidget{
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppPallete.whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppPallete.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Terms & Conditions',
          style: TextStyle(
              color: AppPallete.headings,
              fontWeight: FontWeight.bold,
              fontSize: 35),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Update: 14/08/2024',
              style: TextStyle(
                  fontSize: 17,
                  color: AppPallete.primaryColor,
                  fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 12),
            Text(
              'Welcome to Care Point! These Terms & Conditions govern your use of our medical app. By downloading or using our app, you agree to comply with these terms.',
              style: TextStyle(fontSize: 16, color: AppPallete.textColor),
            ),
            SizedBox(height: 20),
            Text(
              '1. Use of Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'The app provides medical-related services such as tracking health metrics, scheduling appointments, and accessing medical resources.',
                    style: TextStyle(color: AppPallete.textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'The app does not replace professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare provider for medical concerns.',
                    style: TextStyle(color: AppPallete.textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'You must be 18 years or older to use the app.',
                    style: TextStyle(color: AppPallete.textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              '2. Account Registration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'You are required to register for an account to use certain features of the app. You must provide accurate and complete information during registration.',
                    style: TextStyle(color: AppPallete.textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'You are responsible for maintaining the confidentiality of your account and password. You agree to notify us immediately of any unauthorized access to your account.',
                    style: TextStyle(color: AppPallete.textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              '3. Prohibited Activities',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'You agree not to use the app for any illegal activities or in ways that violate our terms.',
                    style: TextStyle(color: AppPallete.textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'You must not attempt to hack, reverse-engineer, or disrupt the functionality of the app.',
                    style: TextStyle(color: AppPallete.textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              '4. Health Data Usage',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'By using the app, you consent to the collection and processing of your health data as described in our Privacy Policy.',
                    style: TextStyle(color: AppPallete.textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'You may withdraw your consent at any time by discontinuing the use of the app and requesting the deletion of your data.',
                    style: TextStyle(color: AppPallete.textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              '5. Limitation of Liability',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'MedicalApp is not liable for any errors, omissions, or inaccuracies in the health information provided by the app.',
                    style: TextStyle(color: AppPallete.textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'The app is provided on an "as is" basis. We make no warranties, either express or implied, regarding the app is functionality or accuracy.',
                    style: TextStyle(color: AppPallete.textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              '6. Termination',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'MedicalApp is not liable for any errors, omissions, or inaccuracies in the health information provided by the app.We may terminate or suspend your access to the app at any time if you breach these terms or engage in any misuse of the app.',
                    style: TextStyle(color: AppPallete.textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              '7. Governing Law',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'These Terms & Conditions shall be governed by and interpreted in accordance with the laws of Sri Lanka. Any disputes or claims arising out of or in connection with these terms shall be subject to the exclusive jurisdiction of the courts of Sri Lanka.',
                    style: TextStyle(color: AppPallete.textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              '8. Modifications to the Terms',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'We reserve the right to modify these Terms & Conditions at any time. Any changes will be communicated to you through an in-app update. Continued use of the app after such modifications will constitute your acknowledgment and acceptance of the revised terms.',
                    style: TextStyle(color: AppPallete.textColor, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 23),
          ],
        ),
      ),
    );
  }
}
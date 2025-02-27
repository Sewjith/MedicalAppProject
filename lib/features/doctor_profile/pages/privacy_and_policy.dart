import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor_profile/profile.dart';

void main(){
  runApp(PrivacyPage());
}
class PrivacyPage extends StatelessWidget{
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: privacyPage(),
    );
  }
}
class privacyPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppPallete.whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_sharp, color: AppPallete.primaryColor),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Profile()),
            );
          },
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(color: AppPallete.headings, fontWeight: FontWeight.bold, fontSize: 35),
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
              'At Care Point, we value your privacy and are committed to protecting the confidentiality and security of your personal information. This Privacy Policy describes how we collect, use, share, and safeguard your information when you use our app Care Point. By using the App, you agree to the practices outlined in this policy.',
              style: TextStyle(fontSize: 16, color: AppPallete.textColor),
            ),
            SizedBox(height: 20),
            Text(
              '1. Information We Collect:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'We collect and process the following types of information to provide and improve our services:',
                    style: TextStyle( fontSize: 16, color: AppPallete.textColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'a. Personal Information:',
                    style: TextStyle(color: Colors.black54, fontSize: 15,fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Professional details such as your name, professional title, qualifications, contact information(email, phone number), and address. Practice details such as specialists, availability, and patient management preferences.',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'b. Health-Related Data:',
                    style: TextStyle(color: Colors.black54, fontSize: 15,fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Patient data, including medical history, diagnoses, treatment plans, medications, and test results. Health-related interactions and consultation records.',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'c. Device and Usage Information:',
                    style: TextStyle(color: Colors.black54, fontSize: 15,fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Information about the devices you use to access the App, including device type, operating system, and browser type. App usage data, such as features accessed, interactions, and usage patterns.',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              '2. How We Use Your Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor ),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'We use your information to:',
                    style: TextStyle( fontSize: 16, color: AppPallete.textColor),
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
                    'Send notifications related to appointments, updates, reminders, and relevant health tips.',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
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
                    'Enable communication between healthcare providers for collaborative care.',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
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
                    'Facilitate patient care by providing access to relevant patient data for treatment, consultations, and follow-ups.',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
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
                    'Comply with legal obligations and safeguard the rights and safety of patients, healthcare providers, and the platform.',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              '3. How We Share Your Information:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'We may share your information in the following cases:',
                    style: TextStyle( fontSize: 16, color: AppPallete.textColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'a. With authorized healthcare professionals:',
                    style: TextStyle(color: Colors.black54, fontSize: 15,fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "If needed for collaboration or patient referrals, we may share your data with other medical providers or healthcare institutions involved in the patient's care.",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'b. With third-party service providers:',
                    style: TextStyle(color: Colors.black54, fontSize: 15,fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'To help manage the App, we may share necessary data with service providers (e.g., cloud storage, payment processors, technical support).',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'c. For legal and compliance reasons:',
                    style: TextStyle(color: Colors.black54, fontSize: 15,fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'We may disclose information if required by law, regulation, or to protect our rights, or the rights of others.',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'd. With your consent:',
                    style: TextStyle(color: Colors.black54, fontSize: 15,fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'We may share your data with third parties if you specifically authorize us to do so.',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'We do not sell or rent your personal information.',
                    style: TextStyle( fontSize: 16, color: AppPallete.textColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              '4. Data Security:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'We employ industry-standard security practices, including encryption, secure servers, and access controls to protect your personal and professional data. However, while we strive to protect your information, please be aware that no security measures are completely foolproof, and we cannot guarantee the absolute security of your data.',
                    style: TextStyle( fontSize: 16, color: AppPallete.textColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              '5. Your Rights & Choices:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'You have the following rights concerning your personal information:',
                    style: TextStyle( fontSize: 16, color: AppPallete.textColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'a. Access and Correction',
                    style: TextStyle(color: Colors.black54, fontSize: 15,fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "You can access and update your professional and practice-related information through your App account settings.",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'b. Patient Data Management',
                    style: TextStyle(color: Colors.black54, fontSize: 15,fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'You can access, review, and update the patient data you manage through the App, in compliance with applicable healthcare laws.',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'c. Notification Preferences:',
                    style: TextStyle(color: Colors.black54, fontSize: 15,fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'You can manage your notification preferences for appointment reminders, updates, and communications.',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'd. Data Deletion:',
                    style: TextStyle(color: Colors.black54, fontSize: 15,fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'In accordance with legal obligations, you can request deletion of certain personal and professional data.',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              '6. Third-Party Links & Services:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'The App may contain links to third-party services or websites. We are not responsible for the privacy practices or content of these external sites. Please review their privacy policies before sharing any information.',
                    style: TextStyle( fontSize: 16, color: AppPallete.textColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              "7. Children's Privacy:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'The App is not intended for use by individuals under the age of 18. We do not knowingly collect personal information from children. If we discover that we have inadvertently collected such data, we will take immediate steps to remove it.',
                    style: TextStyle( fontSize: 16, color: AppPallete.textColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              "8. Changes to This Policy Privacy:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'We may update this Privacy Policy from time to time. If we make significant changes, we will notify you through the App or by email. Your continued use of the App after such changes indicates your acceptance of the updated Privacy Policy.',
                    style: TextStyle( fontSize: 16, color: AppPallete.textColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              "9. Contact Us:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPallete.textColor),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'If you have any questions or concerns about this Privacy Policy or how we handle your information, please contact us:',
                    style: TextStyle( fontSize: 16, color: AppPallete.textColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '[Company Name]',
                    style: TextStyle(color: Colors.black54, fontSize: 15,fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "Email: [email]",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "Phone: [phone]",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "Address: [address]",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
              ],
            ),


          ],
        ),
      ),


    );
  }
}
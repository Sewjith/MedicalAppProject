import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor_profile/pages/settings.dart';

void main(){
  runApp(const notification());
}
class notification extends StatelessWidget {
  const notification({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: notifications(),
    );
  }
}
class notifications extends StatefulWidget {
  @override
  notificationsState createState() => notificationsState();
}

class notificationsState extends State<notifications> {
  bool generalNotification = true;
  bool sound = true;
  bool soundCall = true;
  bool vibrate = false;
  bool specialOffers = false;
  bool payments = true;
  bool promoAndDiscount = false;
  bool cashback = true;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppPallete.whiteColor,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_sharp, color: AppPallete.primaryColor),
          onPressed: (){
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => setting()));
          },
        ),
        title: Text(
          'Notification Settings',
          style: TextStyle(fontSize: 29, color: AppPallete.headings, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSwitchTile("General Notification", generalNotification, (value) {
              setState(() {
                generalNotification = value;
              });
            }),
            buildSwitchTile("Sound", sound, (value) {
              setState(() {
                sound = value;
              });
            }),
            buildSwitchTile("Sound Call", soundCall, (value) {
              setState(() {
                soundCall = value;
              });
            }),
            buildSwitchTile("Vibrate", vibrate, (value) {
              setState(() {
                vibrate = value;
              });
            }),
            buildSwitchTile("Special Offers", specialOffers, (value) {
              setState(() {
                specialOffers = value;
              });
            }),
            buildSwitchTile("Payments", payments, (value) {
              setState(() {
                payments = value;
              });
            }),
            buildSwitchTile("Promo And Discount", promoAndDiscount, (value) {
              setState(() {
                promoAndDiscount = value;
              });
            }),
            buildSwitchTile("Cashback", cashback, (value) {
              setState(() {
                cashback = value;
              });
            }),
          ],
        ),
      ),
    );
  }
  Widget buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 19, color: AppPallete.textColor),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppPallete.primaryColor,
          ),
        ],
      ),
    );
  }
}

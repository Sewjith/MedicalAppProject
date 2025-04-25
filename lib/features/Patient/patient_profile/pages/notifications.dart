import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  bool generalNotification = true;
  bool sound = true;
  bool soundCall = true;
  bool vibrate = false;
  bool specialOffers = false;
  bool payments = true;
  bool promoAndDiscount = false;
  bool cashback = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppPallete.whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_sharp, color: AppPallete.primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Notification Settings',
          style: TextStyle(
              fontSize: 35,
              color: AppPallete.headings,
              fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSwitchTile("General Notification", generalNotification, (value) {
              setState(() {
                generalNotification = value;
              });
            }),
            _buildSwitchTile("Sound", sound, (value) {
              setState(() {
                sound = value;
              });
            }),
            _buildSwitchTile("Sound Call", soundCall, (value) {
              setState(() {
                soundCall = value;
              });
            }),
            _buildSwitchTile("Vibrate", vibrate, (value) {
              setState(() {
                vibrate = value;
              });
            }),
            _buildSwitchTile("Special Offers", specialOffers, (value) {
              setState(() {
                specialOffers = value;
              });
            }),
            _buildSwitchTile("Payments", payments, (value) {
              setState(() {
                payments = value;
              });
            }),
            _buildSwitchTile("Promo And Discount", promoAndDiscount, (value) {
              setState(() {
                promoAndDiscount = value;
              });
            }),
            _buildSwitchTile("Cashback", cashback, (value) {
              setState(() {
                cashback = value;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
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
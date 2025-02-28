import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:go_router/go_router.dart';

class SubscriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Subscription Management",
          style: TextStyle(color: AppPallete.textColor),
        ),
        backgroundColor: AppPallete.whiteColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            const Text(
              "Premium Subscription Features",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.textColor),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enjoy exclusive features with your premium subscription.",
              style: TextStyle(fontSize: 16, color: AppPallete.greyColor),
            ),
            const SizedBox(height: 20),

            // Emergency Assist Feature
            FeatureTile(
              title: "Emergency Assist Feature",
              description:
                  "24/7 immediate consultation with a medical professional in case of emergency.",
              icon: Icons.local_hospital,
              isEnabled: true,
            ),
            const Divider(),

            // Priority Customer Support
            FeatureTile(
              title: "Priority Customer Support",
              description:
                  "Get priority assistance and faster response times for all your queries.",
              icon: Icons.support_agent,
              isEnabled: true,
            ),
            const Divider(),

            // Discount for Appointments
            FeatureTile(
              title: "10% Discount for Appointments",
              description:
                  "Enjoy a 10% discount on every appointment with health professionals.",
              icon: Icons.discount,
              isEnabled: true,
            ),
            const Divider(),

            // Subscription Status
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Subscription Status",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle subscription management action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                  ),
                  child: const Text("Manage Subscription"),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Subscription Plan Information
            const Text(
              "Current Plan: Premium",
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            const SizedBox(height: 5),
            const Text(
              "Renewal Date: 12th March 2025",
              style: TextStyle(fontSize: 16, color: AppPallete.greyColor),
            ),
            const SizedBox(height: 20),

            // Footer with Option to Cancel Subscription
            Center(
              child: TextButton(
                onPressed: () {
                  // Handle cancel subscription action
                },
                child: const Text(
                  "Cancel Subscription",
                  style: TextStyle(color: AppPallete.errorColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isEnabled;

  const FeatureTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 30, color: AppPallete.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.textColor),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style:
                    const TextStyle(fontSize: 14, color: AppPallete.greyColor),
              ),
              const SizedBox(height: 5),
              Text(
                isEnabled ? "Enabled" : "Disabled",
                style: TextStyle(
                    fontSize: 14,
                    color: isEnabled ? Colors.green : Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

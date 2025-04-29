import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PatientPaymentInfo {
  final String name;
  final String addressLine1;
  final String? postalCode;
  final String? city;
  final String? state;
  final String? country;
  final String? p_id;

  PatientPaymentInfo({
    required this.name,
    required this.addressLine1,
    this.postalCode,
    this.city,
    this.state,
    this.country,
    this.p_id,
  });
}

Future<Map<String, dynamic>?> createPaymentIntent({
  required PatientPaymentInfo patientInfo,
  required String currency,
  required String amount,
}) async {
  final url = Uri.parse('https://api.stripe.com/v1/payment_intents');
  final secretKey = dotenv.env["STRIPE_SECRET_KEY"]!;

  final body = {
    'amount': amount,
    'currency': currency.toLowerCase(),
    'automatic_payment_methods[enabled]': 'true',
    'description': "Medical App Payment for ${patientInfo.name} ${patientInfo.p_id}",
    'shipping[name]': patientInfo.name,
    'shipping[address][line1]': patientInfo.addressLine1,
    'shipping[address][postal_code]': patientInfo.postalCode ?? '00000',
    'shipping[address][city]': patientInfo.city ?? 'Unknown City',
    'shipping[address][state]': patientInfo.state ?? 'N/A',
    'shipping[address][country]': patientInfo.country ?? 'LK',
  };

  try {
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $secretKey",
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    print("Stripe Request Body: $body");

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print("Stripe Response: $jsonResponse");
      return jsonResponse;
    } else {
      print(
          "Error creating payment intent. Status Code: ${response.statusCode}");
      print("Error Body: ${response.body}");
      throw Exception(
          "Failed to create payment intent (Status Code: ${response.statusCode})");
    }
  } catch (e) {
    print("Exception during payment intent creation: $e");
    throw Exception("Failed to create payment intent: $e");
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/features/in-app-payments/payment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentHomePage extends StatefulWidget {
  final String appointmentId;

  const PaymentHomePage({
    super.key,
    this.appointmentId = "27a2f9e2-551b-4b48-8018-426d82fd2d76",
  });

  @override
  State<PaymentHomePage> createState() => _PaymentHomePageState();
}

class _PaymentHomePageState extends State<PaymentHomePage> {

  bool isPaymentProcessing = false;
  PatientPaymentInfo? _patientInfo;
  bool _isLoadingPatientData = true;
  String? _loadingError;

  final String amount = "500";
  final String currency = "usd";

  @override
  void initState() {
    super.initState();
    _fetchAppointmentAndPatientData();
  }

  Future<void> _fetchAppointmentAndPatientData() async {
    setState(() {
      _isLoadingPatientData = true;
      _loadingError = null;
      _patientInfo = null;
    });

    try {
      final supabase = Supabase.instance.client;

      print("Fetching appointment details for ID: ${widget.appointmentId}");
      final appointmentResponse = await supabase
          .from('appointments')
          .select('patient_id')
          .eq('id', widget.appointmentId)
          .maybeSingle();

      if (appointmentResponse == null) {
        throw Exception("Appointment with ID ${widget.appointmentId} not found.");
      }

      final String? patientId = appointmentResponse['patient_id'];

      if (patientId == null) {
        throw Exception("Patient ID not found for the given appointment.");
      }
      print("Found Patient ID: $patientId");

      print("Fetching patient details for ID: $patientId");
      final patientResponse = await supabase
          .from('patients')
          .select('first_name, last_name, address')
          .eq('id', patientId)
          .single();

      final String fullName = "${patientResponse['first_name']} ${patientResponse['last_name']}";
      final String address = patientResponse['address'] ?? 'Address not provided';

      setState(() {
        _patientInfo = PatientPaymentInfo(
          app_id: widget.appointmentId,
          name: fullName,
          addressLine1: address,
          postalCode: '',
          city: '',
          state: '',
          country: 'LK',
        );
        _isLoadingPatientData = false;
      });
       print("Successfully fetched patient data: Name = $fullName");

    } catch (e) {
      print("Error fetching appointment/patient data: $e");
      setState(() {
        _isLoadingPatientData = false;
        if (e is Exception && e.toString().contains("Appointment with ID")) {
           _loadingError = e.toString();
        } else if (e is Exception && e.toString().contains("Patient ID not found")) {
           _loadingError = e.toString();
        } else {
          _loadingError = "Failed to load details for payment.";
        }
      });
    }
  }


  Future<void> processPayment() async {
    if (_patientInfo == null || _isLoadingPatientData) {
      showPaymentError("Patient details not loaded yet. Please wait.");
      return;
    }
    if (_loadingError != null) {
      showPaymentError(_loadingError!);
      return;
    }

    setState(() {
      isPaymentProcessing = true;
    });

    try {
      // Use the fetched _patientInfo
      final data = await createPaymentIntent(
        patientInfo: _patientInfo!,
        currency: currency,
        amount: amount,
      );

      if (data == null || !data.containsKey('client_secret')) {
        throw Exception("Invalid payment intent response from server.");
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'Medical App',
          paymentIntentClientSecret: data['client_secret'],
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      showPaymentSuccessDialog();

    } on Exception catch (e) {
      print("Payment Error: $e");
      if (e is StripeException) {
        showPaymentError(
            "Payment failed: ${e.error.localizedMessage ?? e.toString()}");
      } else {
        showPaymentError("An error occurred during payment: ${e.toString()}");
      }
    } catch (e) {
      print("Generic Payment Error: $e");
      showPaymentError("An unexpected error occurred: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          isPaymentProcessing = false;
        });
      }
    }
  }

  void showPaymentSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 60, color: Colors.green),
                const SizedBox(height: 20),
                const Text(
                  "Payment Successful!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Thank you for your payment.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // After paymet will go to below page
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Done"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showPaymentError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, size: 60, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  "Payment Failed",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text("Try Again"),
                )
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Medical App Payment",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.credit_card,
                            size: 50, color: Colors.blueAccent),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Card Payment",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Pay securely using your card",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                if (_isLoadingPatientData)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 10),
                        Text("Loading appointment details..."),
                      ],
                    ),
                  )
                else if (_loadingError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(_loadingError!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                        ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (isPaymentProcessing ||
                              _isLoadingPatientData ||
                              _loadingError != null ||
                              _patientInfo == null)
                          ? null 
                          : processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        disabledBackgroundColor:
                            Colors.grey, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isPaymentProcessing
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              "Proceed to Pay",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
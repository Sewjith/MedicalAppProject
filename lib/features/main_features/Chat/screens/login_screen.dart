import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart'; 
import 'package:medical_app/features/main_features/Chat/models/chat_service.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart'; 


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
 
  final _uuid = const Uuid(); 

  bool _isLoading = false; 
  bool _isLoadingDoctors = false; 
  final _supabase = Supabase.instance.client; 

  
  List<Map<String, dynamic>> _doctorsList = [];
  Map<String, dynamic>? _selectedDoctor; 
  String? _patientId;
  String? _patientName;
  String? _userRole;


  
  late ChatService _chatService;

  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeAndLoadDoctors();
     });
  }

  Future<void> _initializeAndLoadDoctors() async {
     if (!mounted) return;
     setState(() { _isLoading = true; _isLoadingDoctors = true; }); // Start overall loading

     final userState = context.read<AppUserCubit>().state;
     if (userState is AppUserLoggedIn) {
        _patientId = userState.user.uid;
        _patientName = '${userState.user.firstname ?? ''} ${userState.user.lastname ?? ''}'.trim();
         if (_patientName!.isEmpty) {

            _patientName = userState.user.email ?? 'Patient ${_patientId?.substring(0, 6)}'; // Use email or part of ID as fallback
             debugPrint("[LoginScreen] Warning: Patient first/last name missing, using fallback: $_patientName");
        }
        _userRole = userState.user.role;


        _chatService = ChatService(userName: _patientName!, userRole: _userRole!);

        if (_userRole == 'patient' && _patientId != null) {
           try {
             final doctors = await _chatService.getDoctorsWithPastAppointments(_patientId!);
             if (mounted) {
               setState(() {
                  _doctorsList = doctors;
                  _isLoadingDoctors = false;
                  _isLoading = false; // Stop overall loading after doctors load
               });
             }
           } catch (e) {
             if (mounted) {
               setState(() { _isLoading = false; _isLoadingDoctors = false; });
               ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error loading doctors: $e'), backgroundColor: Colors.red),
               );
             }
           }
        } else {

             if (mounted) {
                setState(() { _isLoading = false; _isLoadingDoctors = false; });
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(_userRole != 'patient' ? 'Doctors can initiate chats from their dashboard.' : 'Could not get patient ID.'), backgroundColor: Colors.orange),
                );

             }
        }
     } else {
        // Handle user not logged in
         if (mounted) {
           setState(() { _isLoading = false; _isLoadingDoctors = false; });
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Please log in to start a chat.'), backgroundColor: Colors.red),
           );
           context.go('/login'); // Redirect to main login
         }
     }
  }


  Future<void> _startChat() async {

    if (_patientId == null || _patientName == null || _userRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User details missing.'), backgroundColor: Colors.red),
      );
      return;
    }
     if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor to chat with.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true); // Use general loading state for submission

    try {
      final String selectedDoctorId = _selectedDoctor!['id'];
      final String selectedDoctorName = '${_selectedDoctor!['title'] ?? ''} ${_selectedDoctor!['first_name'] ?? ''} ${_selectedDoctor!['last_name'] ?? ''}'.trim();


      final ids = [_patientId!, selectedDoctorId]..sort();
      final consultationId = 'consult_${ids[0]}_${ids[1]}';

      debugPrint("Generated Consultation ID: $consultationId");
      

      if (mounted) {
         // Navigate using GoRouter and pass all required params
         context.go(
           '/chat/consultation',
           extra: {
             'consultationId': consultationId, // Pass generated ID
             'userName': _patientName!,
             'userRole': _userRole!,
             'recipientName': selectedDoctorName, // Doctor is the recipient
             'doctorName': selectedDoctorName,
             'patientName': _patientName!,
             'doctorId': selectedDoctorId,
             'patientId': _patientId!,
           },
         );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting chat: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

   // Helper function to build display name
   String _buildDoctorDisplayName(Map<String, dynamic> doctor) {
     return '${doctor['title'] ?? ''} ${doctor['first_name'] ?? ''} ${doctor['last_name'] ?? ''}'.trim();
   }

  @override
  Widget build(BuildContext context) {
    // Determine if the current user can start a chat (must be a patient for this flow)
    final bool canStartChat = _userRole == 'patient';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Consultation Chat'),
        centerTitle: true,
      ),
      body: _isLoading // Show loading indicator if initializing
          ? const Center(child: CircularProgressIndicator())
          : !canStartChat // Show message if user is not a patient
            ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Only patients can initiate chats from here.")))
            : Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 80, color: Colors.blue), // Chat icon
                    const SizedBox(height: 20),

 
                     const Text("Select a Doctor you've consulted before:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                     const SizedBox(height: 8),
                     _isLoadingDoctors
                         ? const Center(child: CircularProgressIndicator(strokeWidth: 2,))
                         : _doctorsList.isEmpty
                            ? const Text("No doctors found based on your appointment history.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))
                            : DropdownButtonFormField<Map<String, dynamic>>(
                                value: _selectedDoctor,
                                hint: const Text('Select Doctor'),
                                isExpanded: true,
                                decoration: InputDecoration( // Consistent styling
                                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                   prefixIcon: const Icon(Icons.medical_services_outlined),
                                 ),
                                items: _doctorsList.map((doctor) {
                                  return DropdownMenuItem<Map<String, dynamic>>(
                                    value: doctor,
                                    child: Text(
                                       _buildDoctorDisplayName(doctor), // Use helper for name
                                       style: const TextStyle(color: AppPallete.textColor),
                                       overflow: TextOverflow.ellipsis,
                                     ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                   if (mounted) {
                                     setState(() { _selectedDoctor = value; });
                                   }
                                },
                                validator: (value) => value == null ? 'Please select a doctor' : null,
                              ),
                

                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      // Disable button if loading or no doctor selected or not a patient
                      onPressed: (_isLoading || _isLoadingDoctors || _selectedDoctor == null || !canStartChat) ? null : _startChat,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      icon: (_isLoading && !_isLoadingDoctors) // Show loading only during submission
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.chat),
                      label: Text(
                        (_isLoading && !_isLoadingDoctors) ? 'Starting...' : 'Start Chat',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

final supabase = Supabase.instance.client;

Future<List<Map<String, dynamic>>> getRecommendedDoctors({
  String? gender,
  String? specialty,
  String? language,
  double? maxPrice,
  bool? checkAvailability,
}) async {
  try {
    // Start with a base query for doctors
    var query = supabase
        .from('doctors')
        .select('''
          id, 
          doctor_id,
          first_name,
          last_name,
          title,
          gender,
          specialty,
          years_of_experience,
          amount,
          language
        ''');

    // Apply filters based on user preferences
    if (gender != null) {
      query = query.eq('gender', gender);
    }
    
    if (specialty != null) {
      query = query.eq('specialty', specialty);
    }
    
    if (language != null) {
      query = query.contains('language', [language]);
    }
    
    if (maxPrice != null) {
      query = query.lte('amount', maxPrice);
    }

    // Execute the query
    final doctorsResponse = await query;
    final List<Map<String, dynamic>> doctors = List<Map<String, dynamic>>.from(doctorsResponse);
    
    // If availability check is required, filter doctors based on availability
    if (checkAvailability == true && doctors.isNotEmpty) {
      // Get current date and date one week from now
      final now = DateTime.now();
      final nextWeek = now.add(Duration(days: 7));
      final formattedNow = DateFormat('yyyy-MM-dd').format(now);
      final formattedNextWeek = DateFormat('yyyy-MM-dd').format(nextWeek);
      
      // Create a list to store doctors with availability info
      final List<Map<String, dynamic>> availableDoctors = [];
      
      // Check availability for each doctor
      for (var doctor in doctors) {
        // Query the availability table for this doctor within the next week
        final availabilityResponse = await supabase
            .from('availability')
            .select()
            .eq('doctor_id', doctor['id'])
            .gte('available_date', formattedNow)
            .lte('available_date', formattedNextWeek)
            .eq('status', 'available');
        
        // Add availability data to doctor
        doctor['availability_slots'] = availabilityResponse;
        
        // Only include doctor if they have available slots and availability check is required
        if (!checkAvailability! || (checkAvailability && availabilityResponse.isNotEmpty)) {
          availableDoctors.add(doctor);
        }
      }
      
      print("Found ${availableDoctors.length} doctors with availability out of ${doctors.length} total");
      return availableDoctors;
    }
    
    print("Applied filters - Gender: $gender, Specialty: $specialty, Language: $language, MaxPrice: $maxPrice, CheckAvailability: $checkAvailability");
    print("Found ${doctors.length} doctors matching criteria");
    
    return doctors;
  } catch (e) {
    print("Error fetching doctors: $e");
    return [];
  }
}

// New function to get all available specialties
Future<List<String>> getAvailableSpecialties() async {
  try {
    final response = await supabase
        .from('doctors')
        .select('specialty')
        .order('specialty');
    
    // Extract unique specialties
    final specialties = Set<String>();
    for (var item in response) {
      if (item['specialty'] != null) {
        specialties.add(item['specialty']);
      }
    }
    
    return specialties.toList();
  } catch (e) {
    print("Error fetching specialties: $e");
    return [];
  }
}

// New function to get all available languages
Future<List<String>> getAvailableLanguages() async {
  try {
    final response = await supabase
        .from('doctors')
        .select('language');
    
    // Extract unique languages from the language arrays
    final languages = Set<String>();
    for (var item in response) {
      if (item['language'] != null) {
        for (var lang in item['language']) {
          languages.add(lang);
        }
      }
    }
    
    return languages.toList();
  } catch (e) {
    print("Error fetching languages: $e");
    return ['English']; // Default fallback
  }
}

// New function to get price ranges
Future<List<double>> getAvailablePriceRanges() async {
  try {
    final minResponse = await supabase
        .from('doctors')
        .select('amount')
        .order('amount')
        .limit(1);
    
    final maxResponse = await supabase
        .from('doctors')
        .select('amount')
        .order('amount', ascending: false)
        .limit(1);
    
    double minPrice = 50.0; // Default minimum
    double maxPrice = 250.0; // Default maximum
    
    if (minResponse.isNotEmpty && maxResponse.isNotEmpty) {
      minPrice = double.parse(minResponse[0]['amount'].toString());
      maxPrice = double.parse(maxResponse[0]['amount'].toString());
    }
    
    // Create 5 price ranges between min and max
    final step = (maxPrice - minPrice) / 4;
    return [
      minPrice,
      minPrice + step,
      minPrice + (step * 2),
      minPrice + (step * 3),
      maxPrice,
    ];
  } catch (e) {
    print("Error fetching price ranges: $e");
    return [50.0, 100.0, 150.0, 200.0, 250.0]; // Default fallback
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> messages = [];
  String? selectedSpecialty;
  String? selectedGender;
  String? selectedLanguage;
  double? selectedMaxPrice;
  bool? selectedAvailability;
  
  // Define question stages
  int currentQuestionIndex = 0;
  
  // ScrollController for auto-scrolling
  final ScrollController _scrollController = ScrollController();
  
  // Lists of options - will be populated from database
  List<String> specialties = [];
  List<String> genders = ['Male', 'Female', 'No Preference'];
  List<String> languages = [];
  List<double> priceRanges = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    // Start the questionnaire with welcome message
    _addBotMessage("Welcome to our doctor finder! I'll help you find the right specialist. Let's get started.");
    _loadDataFromDatabase();
  }

  Future<void> _loadDataFromDatabase() async {
    setState(() => isLoading = true);
    
    try {
      // Load specialties
      final dbSpecialties = await getAvailableSpecialties();
      if (dbSpecialties.isNotEmpty) {
        specialties = dbSpecialties;
      } else {
        // Fallback to defaults if no data found
        specialties = ['Cardiologist', 'Dermatologist', 'Pediatrician', 'Orthopedist', 'Neurologist', 'General Practitioner'];
      }
      
      // Load languages
      final dbLanguages = await getAvailableLanguages();
      if (dbLanguages.isNotEmpty) {
        languages = dbLanguages;
      } else {
        // Fallback to defaults if no data found
        languages = ['English', 'Spanish', 'French', 'Chinese', 'Arabic'];
      }
      
      // Load price ranges
      final dbPriceRanges = await getAvailablePriceRanges();
      if (dbPriceRanges.isNotEmpty) {
        priceRanges = dbPriceRanges;
      } else {
        // Fallback to defaults if no data found
        priceRanges = [50.0, 100.0, 150.0, 200.0, 250.0];
      }
      
      setState(() {
        isLoading = false;
      });
      
      // Now that we have the data, ask the first question
      _askNextQuestion();
    } catch (e) {
      print("Error loading data: $e");
      setState(() {
        isLoading = false;
        // Use default values on error
        specialties = ['Cardiologist', 'Dermatologist', 'Pediatrician', 'Orthopedist', 'Neurologist', 'General Practitioner'];
        languages = ['English', 'Spanish', 'French', 'Chinese', 'Arabic'];
        priceRanges = [50.0, 100.0, 150.0, 200.0, 250.0];
      });
      _askNextQuestion();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollToBottom() {
    // Use a small delay to ensure the list has updated before scrolling
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _addBotMessage(String text) {
    setState(() {
      messages.add({'text': text, 'sender': 'bot'});
    });
    _scrollToBottom();
  }
  
  void _addUserMessage(String text) {
    setState(() {
      messages.add({'text': text, 'sender': 'user'});
    });
    _scrollToBottom();
  }
  
  void _askNextQuestion() {
    if (isLoading) {
      _addBotMessage("Loading doctor information...");
      return;
    }
    
    switch (currentQuestionIndex) {
      case 0:
        _addBotMessage("What type of specialist are you looking for?");
        break;
      case 1:
        _addBotMessage("Do you have a preference for doctor gender?");
        break;
      case 2:
        _addBotMessage("Which language do you prefer?");
        break;
      case 3:
        _addBotMessage("What's your maximum budget per consultation?");
        break;
      case 4:
        _addBotMessage("Do you need the doctor to be available this week?");
        break;
      case 5:
        _searchDoctors();
        break;
    }
  }
  
  void _searchDoctors() async {
    _addBotMessage("Searching for doctors that match your criteria...");
    
    // Debug the criteria being used
    print("Search criteria - Specialty: $selectedSpecialty, Gender: $selectedGender, " +
          "Language: $selectedLanguage, MaxPrice: $selectedMaxPrice, " +
          "Availability: $selectedAvailability");
    
    // Process "No Preference" option for gender
    String? genderFilter = (selectedGender == 'No Preference') ? null : selectedGender;
    
    List<Map<String, dynamic>> doctors = await getRecommendedDoctors(
      gender: genderFilter,
      specialty: selectedSpecialty,
      language: selectedLanguage,
      maxPrice: selectedMaxPrice,
      checkAvailability: selectedAvailability,
    );
    
    if (doctors.isNotEmpty) {
      _addBotMessage("Here are the doctors that match your criteria:");
      for (var doctor in doctors) {
        // Format the doctor data from the database structure
        String fullName = "${doctor['title'] ?? ''} ${doctor['first_name']} ${doctor['last_name']}";
        
        // Format availability information
        String availabilityText = "Not available this week";
        if (doctor['availability_slots'] != null && doctor['availability_slots'].isNotEmpty) {
          List<Map<String, dynamic>> availSlots = List<Map<String, dynamic>>.from(doctor['availability_slots']);
          
          if (availSlots.isNotEmpty) {
            // Get the nearest available slot
            availSlots.sort((a, b) {
              DateTime dateA = DateTime.parse(a['available_date']);
              DateTime dateB = DateTime.parse(b['available_date']);
              return dateA.compareTo(dateB);
            });
            
            var nearestSlot = availSlots.first;
            String date = DateFormat('EEE, MMM d').format(DateTime.parse(nearestSlot['available_date']));
            String startTime = nearestSlot['start_time'].substring(0, 5); // Format HH:MM
            availabilityText = "Next available: $date at $startTime";
          }
        }
        
        _addBotMessage(
          "$fullName\n"
          "Specialty: ${doctor['specialty']}\n"
          "Gender: ${doctor['gender']}\n"
          "Languages: ${doctor['language'].join(', ')}\n"
          "Fee: \$${doctor['amount']}\n"
          "$availabilityText"
        );
      }
      _addBotMessage("Found ${doctors.length} matching doctors.");
    } else {
      _addBotMessage("No doctors match all your criteria. Would you like to try with fewer restrictions?");
    }
    
    _addBotMessage("Would you like to search for another doctor?");
    setState(() {
      // Reset for new search
      selectedSpecialty = null;
      selectedGender = null;
      selectedLanguage = null;
      selectedMaxPrice = null;
      selectedAvailability = null;
      currentQuestionIndex = 0;
    });
  }
  
  void _handleResponse(String response, int questionType) {
    _addUserMessage(response);
    
    switch (questionType) {
      case 0:
        selectedSpecialty = response;
        break;
      case 1:
        selectedGender = response;
        break;
      case 2:
        selectedLanguage = response;
        break;
      case 3:
        selectedMaxPrice = double.parse(response.replaceAll('\$', ''));
        break;
      case 4:
        selectedAvailability = response == 'Yes';
        break;
      case 5:
        if (response == 'Yes') {
          // Reset and start over
          selectedSpecialty = null;
          selectedGender = null;
          selectedLanguage = null;
          selectedMaxPrice = null;
          selectedAvailability = null;
          currentQuestionIndex = 0;
          _askNextQuestion();
          return;
        } else {
          _addBotMessage("Thank you for using our service. Have a great day!");
          return;
        }
    }
    
    setState(() {
      currentQuestionIndex++;
    });
    
    _askNextQuestion();
  }
  
  Widget _buildOptionButtons() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppPallete.primaryColor,
        ),
      );
    }
    
    List<Widget> buttons = [];
    
    switch (currentQuestionIndex) {
      case 0:
        buttons = specialties.map((specialty) => 
          _buildButton(specialty, () => _handleResponse(specialty, 0))
        ).toList();
        break;
      case 1:
        buttons = genders.map((gender) => 
          _buildButton(gender, () => _handleResponse(gender, 1))
        ).toList();
        break;
      case 2:
        buttons = languages.map((language) => 
          _buildButton(language, () => _handleResponse(language, 2))
        ).toList();
        break;
      case 3:
        buttons = priceRanges.map((price) => 
          _buildButton('\$${price.toInt()}', () => _handleResponse('\$${price.toInt()}', 3))
        ).toList();
        break;
      case 4:
        buttons = [
          _buildButton('Yes', () => _handleResponse('Yes', 4)),
          _buildButton('No', () => _handleResponse('No', 4)),
        ];
        break;
      case 5:
        buttons = [
          _buildButton('Yes', () => _handleResponse('Yes', 5)),
          _buildButton('No', () => _handleResponse('No', 5)),
        ];
        break;
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: buttons,
    );
  }
  
  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Find a Doctor"),
        backgroundColor: AppPallete.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(10.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? AppPallete.primaryColor : AppPallete.greyColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            color: AppPallete.backgroundColor,
            child: _buildOptionButtons(),
          ),
        ],
      ),
    );
  }
}
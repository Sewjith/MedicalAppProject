//@annotate:replacement:lib/features/main_features/chatbot/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

final supabase = Supabase.instance.client;

// Original doctor fetching function - unchanged
Future<List<Map<String, dynamic>>> getRecommendedDoctors({
 String? gender,
 String? specialty,
 String? language,
 double? maxPrice,
 bool? checkAvailability,
}) async {
 // Your existing implementation remains the same
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
       // Note: The original code had a potential logic issue (!checkAvailability!). Corrected logic:
       // Include if availability check is NOT required OR if it IS required AND slots are found.
       if (checkAvailability != true || (checkAvailability == true && availabilityResponse.isNotEmpty)) {
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

// Helper functions remain the same
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

Future<List<String>> getAvailableLanguages() async {
 try {
   final response = await supabase
       .from('doctors')
       .select('language');
   
   // Extract unique languages from the language arrays
   final languages = Set<String>();
   for (var item in response) {
     if (item['language'] != null && item['language'] is List) { // Check if it's a list
        for (var lang in item['language']) {
         if (lang is String) { // Check if element is a string
            languages.add(lang);
         }
       }
     }
   }
   
   return languages.toList();
 } catch (e) {
   print("Error fetching languages: $e");
   return ['English']; // Default fallback
 }
}

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
   
   // Ensure minPrice is not greater than maxPrice (edge case)
   if (minPrice > maxPrice) {
      final temp = minPrice;
      minPrice = maxPrice;
      maxPrice = temp;
   }
   if (minPrice == maxPrice) { // Handle case where all doctors have the same price
      maxPrice = minPrice + 100; // Add an arbitrary range
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

// New function to analyze user input and extract information
Map<String, dynamic> analyzeUserInput(String input) {
 input = input.toLowerCase();
 Map<String, dynamic> result = {};
 
 // Extract specialty information
 Map<String, List<String>> specialtyKeywords = {
   'Cardiologist': ['heart', 'cardiac', 'cardio', 'chest pain', 'blood pressure', 'hypertension'],
   'Dermatologist': ['skin', 'rash', 'acne', 'derma', 'eczema', 'dermatitis'],
   'Pediatrician': ['child', 'kid', 'baby', 'infant', 'children', 'pediatric'],
   'Orthopedist': ['bone', 'joint', 'fracture', 'ortho', 'knee', 'back pain', 'spine'],
   'Neurologist': ['brain', 'headache', 'migraine', 'neuro', 'nerve', 'seizure'],
   'General Practitioner': ['general', 'regular', 'check up', 'checkup', 'annual', 'routine'],
   'Ophthalmologist': ['eye', 'vision', 'glasses', 'blind', 'sight'],
   'ENT': ['ear', 'nose', 'throat', 'ent', 'hearing', 'sinus'],
   'Psychiatrist': ['mental', 'depression', 'anxiety', 'stress', 'psychiatric'],
 };
 
 for (var specialty in specialtyKeywords.keys) {
   for (var keyword in specialtyKeywords[specialty]!) {
     if (input.contains(keyword)) {
       result['specialty'] = specialty;
       break;
     }
   }
   if (result.containsKey('specialty')) break;
 }
 
 // Extract gender preference
 if (input.contains('female doctor') || input.contains('woman doctor') || 
     input.contains('lady doctor') || input.contains('female physician')) {
   result['gender'] = 'Female';
 } else if (input.contains('male doctor') || input.contains('man doctor')) {
   result['gender'] = 'Male';
 }
 
 // Extract language preference
 Map<String, List<String>> languageKeywords = {
   'English': ['english', 'speak english'],
   'Sinhala': ['sinhala', 'sinhalese'],
   'Tamil': ['tamil', 'Tamil'], // Note: Case-sensitive keyword might be missed due to toLowerCase() earlier
   'Chinese': ['chinese', 'mandarin', 'cantonese'],
   'Hindi': ['hindi', 'indian'],
 };
 
 for (var language in languageKeywords.keys) {
   for (var keyword in languageKeywords[language]!) {
     if (input.contains(keyword)) {
       result['language'] = language;
       break;
     }
   }
   if (result.containsKey('language')) break;
 }
 
 // Extract price information
 RegExp priceRegex = RegExp(r'(\$|\bunder\b|\bless than\b|\bmaximum\b|\bmax\b|\bup to\b) ?(\d+)');
 var priceMatch = priceRegex.firstMatch(input);
 if (priceMatch != null) {
   try {
     double price = double.parse(priceMatch.group(2)!);
     result['maxPrice'] = price;
   } catch (e) {
     print("Error parsing price: $e");
   }
 }
 
 // Extract availability info
 List<String> availabilityKeywords = [
   'urgent', 'asap', 'today', 'tomorrow', 'this week', 'soon', 'emergency', 'immediate', 'right away'
 ];
 
 for (var keyword in availabilityKeywords) {
   if (input.contains(keyword)) {
     result['checkAvailability'] = true;
     break;
   }
 }
 
 return result;
}

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key}); // Add const constructor

 @override
 State<ChatBotScreen> createState() => _ChatBotScreenState(); // Use createState for consistency
}

class _ChatBotScreenState extends State<ChatBotScreen> {
 List<Map<String, dynamic>> messages = [];
 String? selectedSpecialty;
 String? selectedGender;
 String? selectedLanguage;
 double? selectedMaxPrice;
 bool? selectedAvailability;
 
 // Define question stages
 int currentQuestionIndex = -1; // New initial state
 
 // ScrollController for auto-scrolling
 final ScrollController _scrollController = ScrollController();
 
 // Text controller for the input field
 final TextEditingController _textController = TextEditingController();
 
 // Lists of options - will be populated from database
 List<String> specialties = [];
 List<String> genders = ['Male', 'Female', 'No Preference'];
 List<String> languages = [];
 List<double> priceRanges = [];
 bool isLoading = true;
 bool initialMessageSent = false;
 
 @override
 void initState() {
   super.initState();
   // Start with a welcome message that invites free-form input
   _addBotMessage("Welcome to our doctor finder! Please tell me what kind of doctor you're looking for. You can include details like specialty, gender preference, language, budget, or urgency.");
   _loadDataFromDatabase();
 }

 Future<void> _loadDataFromDatabase() async {
    if (!mounted) return; // Check if the widget is still in the tree
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
        languages = ['English', 'Sinhala', 'Tamil']; // Updated defaults
      }
      
      // Load price ranges
      final dbPriceRanges = await getAvailablePriceRanges();
      if (dbPriceRanges.isNotEmpty && dbPriceRanges.length >= 2) { // Ensure at least 2 values for range
        priceRanges = dbPriceRanges;
      } else {
        // Fallback to defaults if no data found or invalid data
        priceRanges = [50.0, 100.0, 150.0, 200.0, 250.0];
      }
      
      if (mounted) { // Check again before setting state
         setState(() {
           isLoading = false;
         });
      }
    } catch (e) {
      print("Error loading data: $e");
       if (mounted) {
         setState(() {
           isLoading = false;
           // Use default values on error
           specialties = ['Cardiologist', 'Dermatologist', 'Pediatrician', 'Orthopedist', 'Neurologist', 'General Practitioner'];
           languages = ['English', 'Sinhala', 'Tamil']; // Updated defaults
           priceRanges = [50.0, 100.0, 150.0, 200.0, 250.0];
         });
       }
    }
  }

 @override
 void dispose() {
   _scrollController.dispose();
   _textController.dispose();
   super.dispose();
 }
 
 void _scrollToBottom() {
   // Use a small delay to ensure the list has updated before scrolling
   Future.delayed(const Duration(milliseconds: 100), () { // Add const
     if (_scrollController.hasClients) {
       _scrollController.animateTo(
         _scrollController.position.maxScrollExtent,
         duration: const Duration(milliseconds: 300), // Add const
         curve: Curves.easeOut,
       );
     }
   });
 }
 
 void _addBotMessage(String text) {
   if (!mounted) return;
   setState(() {
     messages.add({'text': text, 'sender': 'bot'});
   });
   _scrollToBottom();
 }
 
 void _addUserMessage(String text) {
    if (!mounted) return;
   setState(() {
     messages.add({'text': text, 'sender': 'user'});
   });
   _scrollToBottom();
 }
 
 // Process the initial user message
 void _processInitialMessage(String message) {
   _addUserMessage(message);
   
   if (message.trim().isEmpty) {
     _addBotMessage("I didn't catch that. Could you please tell me what kind of doctor you're looking for?");
     return;
   }
   
   // Analyze the user input to extract information
   Map<String, dynamic> extractedInfo = analyzeUserInput(message);
   print("Extracted info: $extractedInfo");
   
   // Set the extracted values
   selectedSpecialty = extractedInfo['specialty'];
   selectedGender = extractedInfo['gender'];
   selectedLanguage = extractedInfo['language'];
   selectedMaxPrice = extractedInfo['maxPrice'];
   selectedAvailability = extractedInfo['checkAvailability'];
   
   // Summarize what we understood
   List<String> understood = [];
   if (selectedSpecialty != null) understood.add("looking for a $selectedSpecialty");
   if (selectedGender != null) understood.add("preference for $selectedGender doctors");
   if (selectedLanguage != null) understood.add("speaking $selectedLanguage");
   if (selectedMaxPrice != null) understood.add("maximum budget of \$${selectedMaxPrice!.toInt()}");
   if (selectedAvailability == true) understood.add("available this week");
   
   if (understood.isEmpty) {
     _addBotMessage("Thanks for your message. Let me help you find the right doctor. I'll need to ask a few questions.");
   } else {
     _addBotMessage("I understand you're ${understood.join(', ')}. Let me fill in the missing details.");
   }
   
   // Determine which question to ask next
   if (selectedSpecialty == null) {
     currentQuestionIndex = 0;
   } else if (selectedGender == null) {
     currentQuestionIndex = 1;
   } else if (selectedLanguage == null) {
     currentQuestionIndex = 2;
   } else if (selectedMaxPrice == null) {
     currentQuestionIndex = 3;
   } else if (selectedAvailability == null) {
     currentQuestionIndex = 4;
   } else {
     // We have all the info, go straight to search
     currentQuestionIndex = 5;
   }
   
   if (!mounted) return;
   setState(() {
     initialMessageSent = true;
   });
   
   _askNextQuestion();
 }
 
 void _askNextQuestion() {
    if (!mounted) return;
   if (isLoading) {
     _addBotMessage("Loading doctor information...");
     return;
   }
   
   switch (currentQuestionIndex) {
     case 0:
       if (selectedSpecialty == null) {
         _addBotMessage("What type of specialist are you looking for?");
       } else {
         currentQuestionIndex++;
         _askNextQuestion();
       }
       break;
     case 1:
       if (selectedGender == null) {
         _addBotMessage("Do you have a preference for doctor gender?");
       } else {
         currentQuestionIndex++;
         _askNextQuestion();
       }
       break;
     case 2:
       if (selectedLanguage == null) {
         _addBotMessage("Which language do you prefer?");
       } else {
         currentQuestionIndex++;
         _askNextQuestion();
       }
       break;
     case 3:
       if (selectedMaxPrice == null) {
         _addBotMessage("What's your maximum budget per consultation?");
       } else {
         currentQuestionIndex++;
         _askNextQuestion();
       }
       break;
     case 4:
       if (selectedAvailability == null) {
         _addBotMessage("Do you need the doctor to be available this week?");
       } else {
         currentQuestionIndex++;
         _askNextQuestion();
       }
       break;
     case 5:
       _searchDoctors();
       break;
   }
 }
 
 void _searchDoctors() async {
    if (!mounted) return;
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
   
   if (!mounted) return;

   if (doctors.isNotEmpty) {
     _addBotMessage("Here are the doctors that match your criteria:");
     for (var doctor in doctors) {
       // Format the doctor data from the database structure
       String fullName = "${doctor['title'] ?? ''} ${doctor['first_name']} ${doctor['last_name']}".trim();
       
       // Format availability information if checked
       String availabilityText = ""; // Default to empty if not checked
        if (selectedAvailability == true) {
          availabilityText = "Not available this week"; // Default if checked but no slots
          if (doctor['availability_slots'] != null && doctor['availability_slots'].isNotEmpty) {
            List<Map<String, dynamic>> availSlots = List<Map<String, dynamic>>.from(doctor['availability_slots']);
            
            if (availSlots.isNotEmpty) {
              // Get the nearest available slot
              availSlots.sort((a, b) {
                try {
                    DateTime dateA = DateTime.parse(a['available_date']);
                    DateTime dateB = DateTime.parse(b['available_date']);
                    return dateA.compareTo(dateB);
                } catch (e) {
                   print("Error parsing availability date: $e");
                   return 0; // Keep original order on error
                }
              });
              
              var nearestSlot = availSlots.first;
              try {
                 String date = DateFormat('EEE, MMM d').format(DateTime.parse(nearestSlot['available_date']));
                 String startTime = nearestSlot['start_time'].substring(0, 5); // Format HH:MM
                 availabilityText = "Next available: $date at $startTime";
              } catch (e) {
                 print("Error formatting nearest slot: $e");
                 availabilityText = "Error checking availability";
              }
            }
          }
        }
       
       // Safely access potentially null language list
       String languagesString = "N/A";
        if (doctor['language'] != null && doctor['language'] is List && doctor['language'].isNotEmpty) {
          languagesString = doctor['language'].join(', ');
        }

       _addBotMessage(
         "$fullName\n"
         "Specialty: ${doctor['specialty'] ?? 'N/A'}\n" // Add null checks
         "Gender: ${doctor['gender'] ?? 'N/A'}\n"
         "Languages: $languagesString\n"
         "Fee: \$${doctor['amount'] ?? 'N/A'}\n"
         "${selectedAvailability == true ? availabilityText : ''}" // Only show availability if checked
       );
     }
     _addBotMessage("Found ${doctors.length} matching doctors.");
   } else {
     _addBotMessage("No doctors match all your criteria. Would you like to try with fewer restrictions?");
     // Consider adding a "Yes/No" button here to restart with modifications
   }
   
   _addBotMessage("Would you like to search for another doctor?");
    if (!mounted) return;
   setState(() {
     // Reset for new search
     selectedSpecialty = null;
     selectedGender = null;
     selectedLanguage = null;
     selectedMaxPrice = null;
     selectedAvailability = null;
     currentQuestionIndex = 5; // Go to the "Search again?" question
     // Keep initialMessageSent = true so it asks the "Search again?" question
   });
    _askNextQuestion(); // Ask the "Search again?" question
 }
 
 void _handleResponse(String response, int questionType) {
    if (!mounted) return;
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
       try {
         // More robust price parsing
         String priceString = response.replaceAll(RegExp(r'[^\d.]'), ''); // Keep only digits and decimal
         selectedMaxPrice = double.parse(priceString);
       } catch (e) {
          print("Error parsing price response: $e");
          _addBotMessage("Sorry, that doesn't look like a valid price. Let's try that again.");
          // Don't advance the question index, ask again.
          _askNextQuestion();
          return; // Exit function early
       }
       break;
     case 4:
       selectedAvailability = response == 'Yes';
       break;
     case 5: // Response to "Search again?"
       if (response == 'Yes') {
         // Reset and start over
         setState(() {
           initialMessageSent = false; // Allow free text input again
           currentQuestionIndex = -1;
           selectedSpecialty = null;
           selectedGender = null;
           selectedLanguage = null;
           selectedMaxPrice = null;
           selectedAvailability = null;
         });
         _addBotMessage("Okay! What kind of doctor are you looking for this time?");
         // State update will rebuild to show the text input field.
         return; // Exit function
       } else {
         _addBotMessage("Thank you for using our service. Have a great day!");
          // Optionally pop the screen after a delay
         Future.delayed(const Duration(seconds: 2), () {
           if (mounted && context.canPop()) {
             context.pop();
           }
         });
         return; // Exit function
       }
   }
   
   if (!mounted) return;
   setState(() {
     // Only advance if not handling price error or "Search again?"
     if (questionType != 3 || selectedMaxPrice != null) { // Check if price was parsed successfully
        currentQuestionIndex++;
     }
   });
   
   _askNextQuestion();
 }
 
 Widget _buildOptionButtons() {
   if (isLoading) {
     return const Center( // Add const
       child: CircularProgressIndicator(
         color: AppPallete.primaryColor,
       ),
     );
   }
   
   // If we haven't received the initial message yet, show text input field
   if (!initialMessageSent) {
     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add const
       child: Row(
         children: [
           Expanded(
             child: TextField(
               controller: _textController,
               decoration: InputDecoration(
                 hintText: "Describe what you're looking for...",
                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(24),
                   borderSide: const BorderSide(color: AppPallete.primaryColor), // Add const
                 ),
                 filled: true,
                 fillColor: Colors.white,
                 contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), // Adjust padding
               ),
               maxLines: 1,
               textInputAction: TextInputAction.send, // Add action button
               onSubmitted: (text) {
                 if (text.trim().isNotEmpty) { // Only process if not empty
                    _processInitialMessage(text);
                    _textController.clear();
                 }
               },
             ),
           ),
           IconButton(
             icon: const Icon(Icons.send, color: AppPallete.primaryColor), // Add const
             onPressed: () {
                if (_textController.text.trim().isNotEmpty) { // Only process if not empty
                   _processInitialMessage(_textController.text);
                   _textController.clear();
                }
             },
           ),
         ],
       ),
     );
   }
   
   // Otherwise show the appropriate option buttons based on current question
   List<Widget> buttons = [];
   
   switch (currentQuestionIndex) {
     case 0: // Specialty
       // Check if specialties list is empty or not
       if (specialties.isEmpty){
         _addBotMessage("Sorry, I couldn't load the available specialties right now. Please try again later.");
         // Provide an option to manually enter or retry?
       } else {
          buttons = specialties.map((specialty) => 
            _buildButton(specialty, () => _handleResponse(specialty, 0))
          ).toList();
       }
       break;
     case 1: // Gender
       buttons = genders.map((gender) => 
         _buildButton(gender, () => _handleResponse(gender, 1))
       ).toList();
       break;
     case 2: // Language
       if (languages.isEmpty){
         _addBotMessage("Sorry, I couldn't load the available languages right now. Using English as default.");
         _handleResponse('English', 2); // Default to english and move on
       } else {
          buttons = languages.map((language) => 
            _buildButton(language, () => _handleResponse(language, 2))
          ).toList();
       }
       break;
     case 3: // Price Range
       if (priceRanges.isEmpty || priceRanges.length < 2){
         _addBotMessage("Sorry, I couldn't load the price ranges right now. Skipping budget preference.");
         _handleResponse('0', 3); // Set price to 0 (or handle differently) and move on
       } else {
          // Generate price range labels like "Up to $X"
          buttons = priceRanges.map((price) {
             final label = 'Up to \$${price.toInt()}';
             return _buildButton(label, () => _handleResponse(price.toString(), 3)); // Pass the actual price value
          }).toList();
       }
       break;
     case 4: // Availability
       buttons = [
         _buildButton('Yes', () => _handleResponse('Yes', 4)),
         _buildButton('No', () => _handleResponse('No', 4)),
       ];
       break;
     case 5: // Search again?
       buttons = [
         _buildButton('Yes', () => _handleResponse('Yes', 5)),
         _buildButton('No', () => _handleResponse('No', 5)),
       ];
       break;
     default:
       // Should not happen, but good to handle
       buttons = [Text("Something went wrong.")];
       break;
   }
   
   return SingleChildScrollView( // Allow options to scroll if too many
     scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap( // Keep Wrap for multi-line if needed, but SingleChildScrollView helps prevent overflow
         spacing: 8,
         runSpacing: 8,
         // alignment: WrapAlignment.center, // Center alignment within the Wrap
         children: buttons,
      ),
   );
 }
 
 Widget _buildButton(String text, VoidCallback onPressed) {
   return ElevatedButton(
     onPressed: onPressed,
     style: ElevatedButton.styleFrom(
       backgroundColor: AppPallete.primaryColor,
       foregroundColor: Colors.white,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(12),
       ),
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Add const
     ),
     child: Text(text),
   );
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text("Find a Doctor"), // Add const
       backgroundColor: AppPallete.primaryColor,
        foregroundColor: Colors.white, // Ensure title and icons are white
       leading: IconButton(
         icon: const Icon(Icons.arrow_back), // Removed explicit color, uses foregroundColor
         tooltip: "Back", // Add tooltip
         onPressed: () {
            if (context.canPop()) { // Check if navigation is possible
               context.pop(); // Use GoRouter's pop
            } else {
               // Handle case where it cannot pop (e.g., it's the initial route)
               // Maybe navigate to dashboard? context.go('/p_dashboard');
            }
         },
       ),
     ),
     body: Column(
       children: [
         Expanded(
           child: ListView.builder(
             controller: _scrollController,
             padding: const EdgeInsets.all(10.0), // Add const
             itemCount: messages.length,
             itemBuilder: (context, index) {
               final message = messages[index];
               bool isUser = message['sender'] == 'user';
               return Align(
                 alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                 child: Container(
                   padding: const EdgeInsets.all(12), // Add const
                   margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10), // Add const
                   constraints: BoxConstraints(
                     maxWidth: MediaQuery.of(context).size.width * 0.75,
                   ),
                   decoration: BoxDecoration(
                     color: isUser ? AppPallete.primaryColor : AppPallete.greyColor.withOpacity(0.8), // Slightly transparent bot messages
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Text(
                     message['text']!,
                     style: TextStyle(
                       color: isUser ? Colors.white : Colors.black87, // Improve bot text contrast
                       fontSize: 16,
                     ),
                   ),
                 ),
               );
             },
           ),
         ),
         Container(
           padding: const EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 16), // Adjusted padding
           color: AppPallete.backgroundColor.withOpacity(0.9), // Slightly transparent background
           child: _buildOptionButtons(),
         ),
       ],
     ),
   );
 }
}
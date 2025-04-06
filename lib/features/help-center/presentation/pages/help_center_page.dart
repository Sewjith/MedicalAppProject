import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/help-center/presentation/widgets/auth_field.dart';

class HelpCentrePage extends StatefulWidget {
  const HelpCentrePage({super.key});

  @override
  State<HelpCentrePage> createState() => _HelpCentrePageState();
}

class _HelpCentrePageState extends State<HelpCentrePage> {
  bool showFAQSection = true;
  String selectedCategory = 'Popular Topic';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 25),
            decoration: const BoxDecoration(
              color: AppPallete.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Help Center Icon + Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.help_outline, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Help Center',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'How Can We Assist You?',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 15),

                // Search Bar with white background
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AuthField(
                    hintText: 'Search for Help...',
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tabButton('FAQ', showFAQSection, () {
                  setState(() {
                    showFAQSection = true;
                  });
                }),
                const SizedBox(width: 12),
                _tabButton('Contact Us', !showFAQSection, () {
                  setState(() {
                    showFAQSection = false;
                  });
                }),
              ],
            ),
          ),

          Expanded(
            child: showFAQSection ? _buildFAQSection() : _buildContactUsSection(),
          ),
        ],
      ),
    );
  }

  // FAQ Section
  Widget _buildFAQSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _categoryButton('Popular Topic', selectedCategory == 'Popular Topic'),
              const SizedBox(width: 10),
              _categoryButton('General', selectedCategory == 'General'),
              const SizedBox(width: 10),
              _categoryButton('Services', selectedCategory == 'Services'),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ListView(
              key: ValueKey<String>(selectedCategory),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: _getFilteredFAQItems(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _getFilteredFAQItems() {
    List<Widget> filteredItems = [];
    final allFAQItems = _getAllFAQItems();

    if (searchQuery.isNotEmpty) {
      for (var faq in allFAQItems) {
        if (faq.question.toLowerCase().contains(searchQuery.toLowerCase()) ||
            faq.steps.any((step) => step.toLowerCase().contains(searchQuery.toLowerCase()))) {
          filteredItems.add(faq);
        }
      }

      if (filteredItems.isEmpty) {
        return [const Text("No results found")];
      }
    } else {
      for (var faq in allFAQItems) {
        if (faq.category == selectedCategory) {
          filteredItems.add(faq);
        }
      }
    }

    return filteredItems;
  }

  List<FAQItem> _getAllFAQItems() {
    Map<String, List<Map<String, dynamic>>> faqData = {
      'Popular Topic': [
        {
          'question': 'How do I book an appointment?',
          'steps': [
            'Open the app and go to the Appointments section.',
            'Choose a doctor or clinic from the available list.',
            'Select a preferred time slot and confirm the appointment.',
            'You will receive a confirmation and a reminder notification.',
          ],
        },
        {
          'question': 'How do I consult a doctor?',
          'steps': [
            'Navigate to the Teleconsultation section in the app.',
            'Select a doctor and choose between video or chat consultation.',
            'Pick a convenient time and proceed with the payment if required.',
            'Start your consultation at the scheduled time.',
          ],
        },
        {
          'question': 'How can I get a prescription?',
          'steps': [
            '- Open the app.',
            '- Go to Prescription Management.',
            '- Upload Prescription.',
            '- Get it Approved.',
          ],
        },
        {
          'question': 'How do I reschedule an appointment?',
          'steps': [
            'Go to Appointments.',
            'Select your appointment.',
            'Tap "Reschedule" and choose a new time.',
          ],
        },
        {
          'question': 'Can I cancel a booked appointment?',
          'steps': [
            'Navigate to the Appointments tab.',
            'Tap on the appointment.',
            'Click on "Cancel Appointment".',
          ],
        },
      ],
      'General': [
        {
          'question': 'How do I reset my password?',
          'steps': [
            'Go to the login screen and tap on "Forgot Password".',
            'Enter your registered email or phone number.',
            'Follow the instructions in the email or SMS to reset your password.',
          ],
        },
        {
          'question': 'How do I update my profile?',
          'steps': [
            'Go to the Profile section in the app.',
            'Edit the necessary details such as name, phone number, or email.',
            'Save changes and verify if prompted.',
          ],
        },
        {
          'question': 'How to delete my account?',
          'steps': [
            'Go to Account Settings.',
            'Select Delete Account.',
            'Confirm deletion.',
            'Account will be removed.',
          ],
        },
        {
          'question': 'What payment methods are accepted?',
          'steps': [
            'Credit/Debit Cards',
            'Mobile Wallets',
            'Bank Transfers',
          ],
        },
        {
          'question': 'Is it safe to make payments in the app?',
          'steps': [
            'Yes, transactions are secured with industry-standard encryption.',
          ],
        },
      ],
      'Services': [
        {
          'question': 'What is the Symptom Checker?',
          'steps': [
            'Enter your symptoms in the Symptom Checker section.',
            'The AI will analyze and suggest possible conditions.',
            'Follow the guidance on whether to seek medical attention.',
          ],
        },
        {
          'question': 'How does the Medication Reminder work?',
          'steps': [
            'Go to the Medication Reminder section.',
            'Add a new reminder by entering medicine details and schedule.',
            'Enable notifications to receive reminders at the set times.',
          ],
        },
        {
          'question': 'How to access digital health records?',
          'steps': [
            'Go to Health Records.',
            'Upload your documents.',
            'View past records.',
            'Download if needed.',
          ],
        },
        {
          'question': 'How do I upload my medical history?',
          'steps': [
            'Go to the Health Records section.',
            'Tap "Upload" and select documents.',
          ],
        },
        {
          'question': 'Are my health records secure?',
          'steps': [
            'Yes, all records are stored securely using encryption protocols.',
          ],
        },
        {
          'question': 'How does the doctor recommendation chatbot work?',
          'steps': [
            'Tap on the Chatbot icon.',
            'Enter your symptoms or questions.',
            'The bot will suggest suitable doctors or departments.',
          ],
        },
        {
          'question': 'Can I view old prescriptions?',
          'steps': [
            'Go to the Prescriptions tab.',
            'Tap on "History" to view previous records.',
          ],
        },
        {
          'question': 'How do I refill a prescription?',
          'steps': [
            'Select your active prescription.',
            'Tap on "Refill Request".',
          ],
        },
        {
          'question': 'What are the requirements for a video consultation?',
          'steps': [
            'Stable internet connection.',
            'Device with a camera and microphone.',
          ],
        },
        {
          'question': 'Can I access past teleconsultation notes?',
          'steps': [
            'Yes, notes are saved under your Health Records.',
          ],
        },
        {
          'question': 'What should I do in an emergency?',
          'steps': [
            'Tap the red Emergency icon on the home screen.',
            'It will dial the local emergency number or notify your emergency contacts.',
          ],
        },
        {
          'question': 'Can I set reminders for multiple medications?',
          'steps': [
            'Yes, add each medication with its respective time and dosage.',
          ],
        },
        {
          'question': 'What happens if I miss a dose?',
          'steps': [
            'The app will log it and suggest what to do next.',
          ],
        },
        {
          'question': 'How do I add a new symptom?',
          'steps': [
            'Go to the Symptoms Tracker.',
            'Tap "Add Symptom", describe it, and save.',
          ],
        },
        {
          'question': 'Can I track past symptoms?',
          'steps': [
            'Yes, view your health trend graph and symptom log.',
          ],
        },
        {
          'question': 'Are the articles medically reviewed?',
          'steps': [
            'Yes, all content is reviewed by certified professionals.',
          ],
        },
        {
          'question': 'Can I save an article for later?',
          'steps': [
            'Tap the bookmark icon on any article.',
          ],
        },
      ],
    };

    List<FAQItem> items = [];
    faqData.forEach((category, faqs) {
      for (var faq in faqs) {
        items.add(
          FAQItem(
            question: faq['question'],
            steps: List<String>.from(faq['steps']),
            category: category,
          ),
        );
      }
    });
    return items;
  }

  Widget _buildContactUsSection() {
    List<Map<String, dynamic>> contactOptions = [
      {'icon': Icons.headset_mic, 'title': 'Customer Service'},
      {'icon': Icons.public, 'title': 'Website'},
      {'icon': Icons.message, 'title': 'Chat'},
      {'icon': Icons.facebook, 'title': 'Facebook'},
      {'icon': Icons.camera_alt, 'title': 'Instagram'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: contactOptions.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: Icon(
              contactOptions[index]['icon'],
              color: AppPallete.primaryColor,
            ),
            title: Text(
              contactOptions[index]['title'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'More details about ${contactOptions[index]['title']}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabButton(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppPallete.primaryColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(22),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryButton(String text, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = text;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppPallete.primaryColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.blueGrey,
          ),
        ),
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final List<String> steps;
  final String category;

  const FAQItem({
    super.key,
    required this.question,
    required this.steps,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppPallete.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildRichText(steps[i].startsWith('- ') ? steps[i].substring(2) : steps[i]),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRichText(String step) {
    // For appointment booking
    if (step.contains('Appointments section')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Open the app and go to the '),
            const TextSpan(
              text: 'Appointments section',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      );
    }
    // For doctor selection
    else if (step.contains('doctor or clinic')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Choose a '),
            const TextSpan(
              text: 'doctor or clinic',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' from the available list.'),
          ],
        ),
      );
    }
    // For time slot selection
    else if (step.contains('preferred time slot')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Select a '),
            const TextSpan(
              text: 'preferred time slot',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' and confirm the appointment.'),
          ],
        ),
      );
    }
    // For teleconsultation
    else if (step.contains('Teleconsultation section')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Navigate to the '),
            const TextSpan(
              text: 'Teleconsultation section',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' in the app.'),
          ],
        ),
      );
    }
    // For video/chat consultation
    else if (step.contains('video or chat consultation')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Select a doctor and choose between '),
            const TextSpan(
              text: 'video or chat consultation',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      );
    }
    // For prescription management
    else if (step.contains('Prescription Management')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Go to '),
            const TextSpan(
              text: 'Prescription Management',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      );
    }
    // For forgot password
    else if (step.contains('Forgot Password')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Go to the login screen and tap on "'),
            const TextSpan(
              text: 'Forgot Password',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '".'),
          ],
        ),
      );
    }
    // For profile section
    else if (step.contains('Profile section')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Go to the '),
            const TextSpan(
              text: 'Profile section',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' in the app.'),
          ],
        ),
      );
    }
    // For account settings
    else if (step.contains('Account Settings')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Go to '),
            const TextSpan(
              text: 'Account Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      );
    }
    // For delete account
    else if (step.contains('Delete Account')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Select '),
            const TextSpan(
              text: 'Delete Account',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      );
    }
    // For symptom checker
    else if (step.contains('Symptom Checker')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Enter your symptoms in the '),
            const TextSpan(
              text: 'Symptom Checker section',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      );
    }
    // For medication reminder
    else if (step.contains('Medication Reminder')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Go to the '),
            const TextSpan(
              text: 'Medication Reminder section',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      );
    }
    // For health records
    else if (step.contains('Health Records')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Go to '),
            const TextSpan(
              text: 'Health Records',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      );
    }
    // For Upload Prescription
    else if (step.contains('Upload Prescription')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(
              text: 'Upload Prescription',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      );
    }
    // For Appointments tab
    else if (step.contains('Appointments tab')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Navigate to the '),
            const TextSpan(
              text: 'Appointments tab',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      );
    }
    // For Prescriptions tab
    else if (step.contains('Prescriptions tab')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Go to the '),
            const TextSpan(
              text: 'Prescriptions tab',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      );
    }
    // For Symptoms Tracker
    else if (step.contains('Symptoms Tracker')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Go to the '),
            const TextSpan(
              text: 'Symptoms Tracker',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      );
    }
    else if (step.contains('Emergency icon')) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            const TextSpan(text: 'Tap the red '),
            const TextSpan(
              text: 'Emergency icon',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' on the home screen.'),
          ],
        ),
      );
    }
    else {
      return Text(
        step,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
      );
    }
  }
}
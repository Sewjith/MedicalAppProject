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
                const Text(
                  'Help Center',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'How Can We Assist You?',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 15),
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
            child:
                showFAQSection ? _buildFAQSection() : _buildContactUsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _categoryButton(
                'Popular Topic',
                selectedCategory == 'Popular Topic',
              ),
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
            faq.steps.any(
              (step) => step.toLowerCase().contains(searchQuery.toLowerCase()),
            )) {
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
          'question': 'How to update profile information?',
          'steps': [
            'Go to Settings.',
            'Click Edit Profile.',
            'Update necessary fields.',
            'Save changes.',
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
          'question': 'How to set medication reminders?',
          'steps': [
            'Open the app.',
            'Go to Medication Reminder.',
            'Set your medication details.',
            'Receive reminders on time.',
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
        children: steps
            .map(
              (step) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  step,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

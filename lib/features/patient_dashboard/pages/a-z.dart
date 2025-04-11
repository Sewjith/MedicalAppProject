import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/patient_dashboard/pages/male_doctors.dart';
import 'package:medical_app/features/patient_dashboard/pages/favorite.dart';
import 'package:medical_app/features/patient_dashboard/pages/female_doctors.dart';
import 'package:medical_app/features/patient_dashboard/pages/a-z_db.dart';

class AZScreen extends StatefulWidget {
  final String patientId;

  const AZScreen({super.key, required this.patientId});

  @override
  State<AZScreen> createState() => _AZScreenState();
}

class _AZScreenState extends State<AZScreen> with SingleTickerProviderStateMixin {
  final AZDB _azdb = AZDB();
  int _selectedIndex = 0;
  TabController? _tabController;
  String _activeSort = 'A-Z';
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await _azdb.getAllDoctors();
      setState(() {
        _doctors = doctors;
        _filteredDoctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading doctors: $e')),
      );
    }
  }

  Future<void> _toggleFavorite(String doctorId, bool isCurrentlyFavorited) async {
    try {
      if (isCurrentlyFavorited) {
        await _azdb.removeFavorite(widget.patientId, doctorId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites')),
        );
      } else {
        await _azdb.addFavorite(widget.patientId, doctorId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites')),
        );
      }
      await _loadDoctors();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating favorite: $e')),
      );
    }
  }

  void _handleSortSelection(String selectedSort) {
    setState(() {
      _activeSort = selectedSort;
      switch (selectedSort) {
        case 'A-Z':
          _filteredDoctors.sort((a, b) =>
              '${a['firstName']} ${a['lastName']}'
                  .compareTo('${b['firstName']} ${b['lastName']}'));
          break;
        case 'Favorites':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Favorite(patientId: widget.patientId)),
          );
          break;
      }
    });
  }

  void _filterDoctors(String query) {
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        final name = '${doctor['title']} ${doctor['firstName']} ${doctor['lastName']}'.toLowerCase();
        final specialty = doctor['specialty'].toLowerCase();
        return name.contains(query.toLowerCase()) || specialty.contains(query.toLowerCase());
      }).toList();
    });
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final fullName = '${doctor['title']} ${doctor['firstName']} ${doctor['lastName']}';

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: InkWell(
        onTap: () {
          print('Selected doctor: $fullName');
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 38,
                backgroundImage: AssetImage('assets/images/doctor.jpg'),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      doctor['specialty'],
                      style: TextStyle(
                          fontSize: 16,
                          color: AppPallete.primaryColor),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            print('Info for: $fullName');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPallete.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            'Info',
                            style: TextStyle(
                                color: AppPallete.secondaryColor,
                                fontSize: 17),
                          ),
                        ),
                        const SizedBox(width: 95),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppPallete.whiteColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              print('Schedule for: $fullName');
                            },
                            icon: Icon(Icons.calendar_month_rounded, color: AppPallete.primaryColor),
                          ),
                        ),
                        const SizedBox(width: 5),
                        FutureBuilder<bool>(
                          future: _azdb.isDoctorFavorited(widget.patientId, doctor['id']),
                          builder: (context, snapshot) {
                            final isFavorited = snapshot.data ?? false;
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppPallete.whiteColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () => _toggleFavorite(doctor['id'], isFavorited),
                                icon: Icon(
                                  isFavorited ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorited ? Colors.blue : AppPallete.primaryColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppPallete.transparentColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppPallete.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'A-Z',
          style: TextStyle(
              fontSize: 35,
              color: AppPallete.headings,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppPallete.primaryColor),
            onPressed: () async {
              final selectedDoctor = await showSearch<Map<String, dynamic>>(
                context: context,
                delegate: DoctorSearch(_doctors),
              );
              if (selectedDoctor != null) {
                final fullName = '${selectedDoctor['title']} ${selectedDoctor['firstName']} ${selectedDoctor['lastName']}';
                print('Selected doctor from search: $fullName');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const SizedBox(width: 5),
                const Text(
                  'Sort By:',
                  style: TextStyle(fontSize: 20, color: Colors.black45),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: () => _handleSortSelection('A-Z'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _activeSort == 'A-Z'
                        ? AppPallete.primaryColor
                        : Colors.blue.shade100,
                  ),
                  child: Text(
                    'A-Z',
                    style: TextStyle(color: AppPallete.whiteColor),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  decoration: BoxDecoration(
                    color: _activeSort == 'Favorites'
                        ? AppPallete.primaryColor
                        : Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Favorite(patientId: widget.patientId)),
                      );
                    },
                    icon: const Icon(Icons.favorite_border_outlined,
                        color: AppPallete.whiteColor),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  decoration: BoxDecoration(
                    color: _activeSort == 'Male'
                        ? AppPallete.primaryColor
                        : Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MaleDoctorScreen(patientId: widget.patientId),
                        ),);
                    },
                    icon: const Icon(Icons.male_outlined,
                        color: AppPallete.whiteColor),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  decoration: BoxDecoration(
                    color: _activeSort == 'Female'
                        ? AppPallete.primaryColor
                        : Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => FemaleDoctorScreen(patientId: widget.patientId)),
                      );
                    },
                    icon: const Icon(Icons.female_outlined,
                        color: AppPallete.whiteColor),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredDoctors.length,
              itemBuilder: (context, index) {
                return _buildDoctorCard(_filteredDoctors[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorSearch extends SearchDelegate<Map<String, dynamic>> {
  final List<Map<String, dynamic>> doctors;

  DoctorSearch(this.doctors);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: AppPallete.primaryColor),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_sharp, color: AppPallete.primaryColor),
      onPressed: () => close(context, {}),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = doctors.where((doctor) {
      final name = '${doctor['title']} ${doctor['firstName']} ${doctor['lastName']}'.toLowerCase();
      final specialty = '${doctor['specialty']}'.toLowerCase();
      return name.contains(query.toLowerCase()) || specialty.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final doctor = results[index];
        final fullName = '${doctor['title']} ${doctor['firstName']} ${doctor['lastName']}';
        return ListTile(
          title: Text(fullName),
          subtitle: Text(doctor['specialty']),
          onTap: () => close(context, doctor),
        );
      },
    );
  }
}



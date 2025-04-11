import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/patient_dashboard/pages/a-z.dart';
import 'package:medical_app/features/patient_dashboard/pages/favorite.dart';
import 'package:medical_app/features/patient_dashboard/pages/female_db.dart';
import 'package:medical_app/features/patient_dashboard/pages/male_doctors.dart';

class FemaleDoctorScreen extends StatefulWidget {
  final String patientId;

  const FemaleDoctorScreen({super.key, required this.patientId});

  @override
  _FemaleDoctorScreenState createState() => _FemaleDoctorScreenState();
}

class _FemaleDoctorScreenState extends State<FemaleDoctorScreen> {
  final DoctorDB _doctorDB = DoctorDB();
  final FavoriteDB _favoriteDB = FavoriteDB();
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  bool _isLoading = true;
  String _activeSort = 'Female';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFemaleDoctors();
  }

  Future<void> _loadFemaleDoctors() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final doctors = await _doctorDB.getFemaleDoctors();
      setState(() {
        _doctors = doctors;
        _filteredDoctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load doctors: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(String doctorId) async {
    try {
      final isFavorited = await _favoriteDB.isDoctorFavorited(widget.patientId, doctorId);
      if (isFavorited) {
        await _favoriteDB.removeFavorite(widget.patientId, doctorId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites')),
        );
      } else {
        await _favoriteDB.addFavorite(widget.patientId, doctorId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites')),
        );
      }

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorite: ${e.toString()}')),
      );
    }
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
              backgroundImage: AssetImage('assets/images/female doctor.jpg'),
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
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    doctor['specialty'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppPallete.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text(
                          'Info',
                          style: TextStyle(color: AppPallete.secondaryColor, fontSize: 17),
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
                          onPressed: () {},
                          icon: const Icon(
                            Icons.calendar_month_rounded,
                            color: AppPallete.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      FutureBuilder<bool>(
                        future: _favoriteDB.isDoctorFavorited(widget.patientId, doctor['id']),
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
                              onPressed: () => _toggleFavorite(doctor['id']),
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
          'Female Doctors',
          style: TextStyle(
            fontSize: 35,
            color: AppPallete.headings,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppPallete.primaryColor),
            onPressed: () async {
              final selectedDoctor = await showSearch<Map<String, dynamic>?>(
                context: context,
                delegate: DoctorSearch(_doctors.map((d) => {
                  'name': '${d['title']} ${d['firstName']} ${d['lastName']}',
                  'specialty': d['specialty'],
                  'image': 'assets/images/female doctor.jpg',
                  'id': d['id']
                }).toList()),
              );
              if (selectedDoctor != null) {
                // Handle selected doctor
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _doctors.isEmpty
          ? const Center(child: Text('No female doctors found'))
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AZScreen(patientId: widget.patientId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _activeSort == 'A-Z'
                        ? AppPallete.primaryColor
                        : Colors.blue.shade100,
                  ),
                  child: const Text(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FavoriteScreen(patientId: widget.patientId),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.favorite_border_outlined,
                      color: AppPallete.whiteColor,
                    ),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MaleDoctorScreen(patientId: widget.patientId),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.male_outlined,
                      color: AppPallete.whiteColor,
                    ),
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
                    onPressed: () {},
                    icon: const Icon(
                      Icons.female_outlined,
                      color: AppPallete.whiteColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadFemaleDoctors,
              child: ListView.builder(
                itemCount: _filteredDoctors.length,
                itemBuilder: (context, index) {
                  return _buildDoctorCard(_filteredDoctors[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorSearch extends SearchDelegate<Map<String, dynamic>?> {
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
      icon: const Icon(Icons.arrow_back_ios_new, color: AppPallete.primaryColor),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = doctors.where((doctor) {
      final name = doctor['name'].toLowerCase();
      final specialty = doctor['specialty'].toString().toLowerCase();
      return name.contains(query.toLowerCase()) || specialty.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final doctor = results[index];
        return ListTile(
          leading: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/female doctor.jpg'),
          ),
          title: Text(doctor['name']),
          subtitle: Text(doctor['specialty'].toString()),
          onTap: () => close(context, doctor),
        );
      },
    );
  }
}
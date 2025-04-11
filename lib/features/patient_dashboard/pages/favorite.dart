import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/patient_dashboard/pages/a-z.dart';
import 'package:medical_app/features/patient_dashboard/pages/favorite_db.dart';
import 'package:medical_app/features/patient_dashboard/pages/male_doctors.dart';
import 'package:medical_app/features/patient_dashboard/pages/female_doctors.dart';

class Favorite extends StatelessWidget {
  final String patientId;

  const Favorite({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FavoriteScreen(patientId: patientId),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FavoriteScreen extends StatefulWidget {
  final String patientId;

  const FavoriteScreen({super.key, required this.patientId});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteDB _favoriteDB = FavoriteDB();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _favoriteDoctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  bool _isLoading = true;
  String _activeSort = 'Favorites';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavoriteDoctors();
  }

  Future<void> _loadFavoriteDoctors() async {
    try {
      final favorites = await _favoriteDB.getPatientFavorites(widget.patientId);
      setState(() {
        _favoriteDoctors = favorites;
        _filteredDoctors = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading favorites: $e')),
      );
    }
  }

  Future<void> _removeFavorite(String doctorId) async {
    try {
      await _favoriteDB.removeFavorite(widget.patientId, doctorId);
      await _loadFavoriteDoctors();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from favorites')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing favorite: $e')),
      );
    }
  }

  void _filterDoctors(String query) {
    setState(() {
      _filteredDoctors = _favoriteDoctors.where((doctor) {
        final name = '${doctor['title']} ${doctor['firstName']} ${doctor['lastName']}'.toLowerCase();
        final specialty = doctor['specialty'].toLowerCase();
        return name.contains(query.toLowerCase()) ||
            specialty.contains(query.toLowerCase());
      }).toList();
    });
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final fullName = '${doctor['title']} ${doctor['firstName']} ${doctor['lastName']}';

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: Colors.blue[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    child: Row(
                      children: [
                        Icon(Icons.verified, color: AppPallete.headings, size: 20),
                        SizedBox(width: 5),
                        Text(
                          'Professional Doctor',
                          style: TextStyle(color: AppPallete.headings, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/doctor.jpg'),
                ),
                title: Text(
                  fullName,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppPallete.textColor
                  ),
                ),
                subtitle: Text(doctor['specialty']),
                trailing: IconButton(
                  icon: Icon(Icons.favorite, color: Colors.blue),
                  onPressed: () => _removeFavorite(doctor['id']),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    backgroundColor: AppPallete.headings,
                  ),
                  child: Text(
                    'Make Appointment',
                    style: TextStyle(color: AppPallete.secondaryColor, fontSize: 19),
                  ),
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
        title: Text(
          'Favorites',
          style: TextStyle(
              fontSize: 35,
              color: AppPallete.primaryColor,
              fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppPallete.primaryColor),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DoctorSearch(_favoriteDoctors.map((d) => {
                  'name': '${d['title']} ${d['firstName']} ${d['lastName']}',
                  'specialty': d['specialty'].toString(),
                  'image': 'assets/images/doctor.jpg'
                }).toList().cast<Map<String, String>>()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _favoriteDoctors.isEmpty
          ? Center(child: Text('No favorite doctors found'))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Sort By:',
                  style: TextStyle(fontSize: 20, color: Colors.black45),),
                SizedBox(width: 4,),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AZScreen(patientId: widget.patientId)));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _activeSort == 'A-Z' ? Colors.blue : Colors.blue.shade100),
                  child: Text('A-Z', style: TextStyle(color: AppPallete.whiteColor)),
                ),
                SizedBox(width: 4,),
                Container(
                  decoration: BoxDecoration(
                    color: _activeSort == 'Favorites'
                        ? AppPallete.primaryColor
                        : Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => _handleSortSelection('Favorites'),
                    icon: Icon(Icons.favorite_border_outlined, color: AppPallete.whiteColor),
                  ),
                ),
                SizedBox(width: 4),
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
                    icon: Icon(Icons.male_outlined, color: AppPallete.whiteColor),
                  ),
                ),
                SizedBox(width: 4),
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
                    icon: Icon(Icons.female_outlined, color: AppPallete.whiteColor),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
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

  void _handleSortSelection(String selectedSort) {
    setState(() {
      _activeSort = selectedSort;
      switch (selectedSort) {
        case 'A-Z':
          _filteredDoctors.sort((a, b) =>
              '${a['title']} ${a['firstName']} ${a['lastName']}'
                  .compareTo('${b['title']} ${b['firstName']} ${b['lastName']}'));
          break;
        case 'Favorites':
        // Sort by most recently added
          _filteredDoctors.sort((a, b) =>
              b['createdAt'].compareTo(a['createdAt']));
          break;
      }
    });
  }
}

class DoctorSearch extends SearchDelegate {
  final List<Map<String, String>> doctors;

  DoctorSearch(this.doctors);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: AppPallete.primaryColor),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new_sharp, color: AppPallete.primaryColor),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = doctors.where((doctor) {
      return doctor['name']!.toLowerCase().contains(query.toLowerCase()) ||
          doctor['specialty']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index]['name']!),
          subtitle: Text(results[index]['specialty']!),
          leading: CircleAvatar(
            backgroundImage: AssetImage(results[index]['image']!),
          ),
          onTap: () {
            close(context, results[index]);
          },
        );
      },
    );
  }
}
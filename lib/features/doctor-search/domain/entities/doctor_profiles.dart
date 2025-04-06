class DoctorProfiles {
  final int id;
  final String pictueURl;
  final String firstName;
  final String lastName;
  final String? experience;
  final String contact;
  final String email;
  final String? location;

  DoctorProfiles({
    required this.id,
    required this.pictueURl,
    required this.firstName,
    required this.lastName,
    this.experience,
    required this.contact,
    required this.email,
    this.location,
  });

  factory DoctorProfiles.fromJson(Map<String, dynamic> json) {
    return DoctorProfiles(
      id: json['id'] as int,
      pictueURl: json['picture_url'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      experience: json['experience'] as String?,
      contact: json['contact'] as String,
      email: json['email'] as String,
      location: json['location'] as String?,
    );
  }
}

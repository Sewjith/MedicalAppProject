class DoctorProfiles {
  final int id;
  final String pictueURl;
  final String firstName;
  final String lastName;
  final String? experience;
  final String contact;
  final String email;
  final String? location;

  DoctorProfiles(
      {required this.id,
      required this.pictueURl,
      required this.firstName,
      required this.lastName,
      this.experience,
      required this.contact,
      required this.email,
      this.location});
}

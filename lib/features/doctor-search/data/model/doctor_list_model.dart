class DoctorListModel {
  final String id;
  final String firstName;
  final String lastName;
  final String specialty;
  final String number;
  final String email;

  DoctorListModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.specialty,
    required this.number,
    required this.email,
  });

  factory DoctorListModel.fromJson(Map<String, dynamic> json) {
    return DoctorListModel(
      id: json['id'] ?? '', 
      firstName: json['firstName'] ?? '', 
      lastName: json['lastName'] ?? '', 
      specialty: json['specialty'] ?? '', 
      number: json['number'] ?? '', 
      email: json['email'] ?? ''
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'specialty': specialty,
      'number': number,
      'email': email,
    };
  }
}
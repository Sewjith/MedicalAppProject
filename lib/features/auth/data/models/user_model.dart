import 'package:medical_app/core/common/entities/user_type.dart';

class UserModel extends UserType {
  final bool isEmailVerified;
  final String? phone;

  UserModel({
    required super.role,
    required super.gender,
    required super.uid,
    required super.email,
    required super.firstname,
    required super.lastname,
    this.isEmailVerified = false,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      role: map['role'] ?? 'guest',
      uid: map['id'] ?? '',
      gender: map['gender'] ?? '',
      email: map['email'] ?? '',
      firstname: map['firstname'] ?? '',
      lastname: map['lastname'] ?? '',
      phone: map['phone'],
      isEmailVerified: map['email_confirmed_at'] != null,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? firstname,
    String? lastname,
    String? gender,
    String? role,
    String? phone,
    bool? isEmailVerified,
  }) {
    return UserModel(
      role: role ?? this.role,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      gender: gender ?? this.gender,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      phone: phone ?? this.phone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'id': uid,
      'email': email,
      'gender': gender,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'email_confirmed_at': isEmailVerified ? DateTime.now().toIso8601String() : null,
    };
  }
}

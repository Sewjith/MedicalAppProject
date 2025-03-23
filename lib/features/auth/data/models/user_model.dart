import 'package:medical_app/core/common/entities/user_type.dart';

class UserModel extends UserType {
  final bool isEmailVerified;
  final String? phone;

  UserModel({
    required super.uid,
    required super.email,
    required super.name,
    this.isEmailVerified = false,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      uid: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'],
      isEmailVerified: map['email_confirmed_at'] != null,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    bool? isEmailVerified,
  }) {
    return UserModel(
      email: email ?? this.email,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'email_confirmed_at': isEmailVerified ? DateTime.now().toIso8601String() : null,
    };
  }
}

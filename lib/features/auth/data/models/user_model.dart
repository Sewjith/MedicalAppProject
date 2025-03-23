import 'package:medical_app/core/common/entities/user_type.dart';

class UserModel extends UserType {
  UserModel({
    required super.uid,
    required super.email,
    required super.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
    );
  }

  UserModel copyWith ({
    String? uid,
    String? email,
    String? name,

  }) {return UserModel(
    email: email ?? this.email,
    uid: uid ?? this.uid,
    name: name ?? this.name,
    );
  }
}

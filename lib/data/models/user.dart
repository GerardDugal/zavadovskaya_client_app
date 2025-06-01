import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String photoPath;
  final List<int> purchasedCourseIds;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.photoPath = '',
    this.purchasedCourseIds = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      photoPath: json['photo_path'] ?? '',
      purchasedCourseIds: List<int>.from(
        json['purchasedCourseIds'] ?? json['purchased_course_ids'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'photo_path': photoPath,
      'purchased_course_ids': purchasedCourseIds,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? photoPath,
    List<int>? purchasedCourseIds,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoPath: photoPath ?? this.photoPath,
      purchasedCourseIds: purchasedCourseIds ?? this.purchasedCourseIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        photoPath,
        purchasedCourseIds,
      ];

  static const empty = User(
    id: '',
    email: '',
    name: '',
    phone: '',
    photoPath: '',
    purchasedCourseIds: [],
  );
}
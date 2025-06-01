import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:zavadovskaya_client_app/data/models/course_content.dart';

class Course extends Equatable {
  final int id;
  final String title;
  final String description;
  final String photoPath;
  final double cost;
  final int categoryId;
  final bool isPaid;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.photoPath,
    required this.cost,
    required this.categoryId,
    this.isPaid = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      photoPath: json['photo_path'] as String,
      cost: (json['cost'] as num).toDouble(),
      categoryId: json['category_id'] as int,
    );
  }

  Course copyWith({
    int? id,
    String? title,
    String? description,
    String? photoPath,
    double? cost,
    int? categoryId,
    bool? isPaid,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      cost: cost ?? this.cost,
      categoryId: categoryId ?? this.categoryId,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        photoPath,
        cost,
        categoryId,
        isPaid,
      ];
}


import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int categoryId;
  final String name;
  final String description;

  const Category({
    required this.categoryId,
    required this.name,
    required this.description,
  });

factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
    };
  }
  @override
  List<Object?> get props =>
      [categoryId, name, description];
}
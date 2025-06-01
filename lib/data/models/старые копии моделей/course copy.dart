// import 'dart:convert';
// import 'package:equatable/equatable.dart';
// import 'package:zavadovskaya_client_app/data/models/course_content.dart';

// class Course extends Equatable {
//   final int courseID;
//   final String title;
//   final String description;
//   final String category;
//   final String thumbnailUrl;
//   final double price;
//   final bool isPaid;
//   final List<CourseContent>? courseContents;

//   const Course({
//     required this.courseID,
//     required this.title,
//     required this.description,
//     required this.category,
//     required this.thumbnailUrl,
//     required this.price,
//     required this.isPaid,
//     this.courseContents,
//   });

//   factory Course.fromJson(Map<String, dynamic> json) {
//     // Проверяем, содержит ли JSON ключ "course"
//     if (json.containsKey('course')) {
//       final courseData = json['course'] as Map<String, dynamic>;
//       final courseContentsData = json['courseContents'] as List<dynamic>?;

//       return Course(
//         courseID: courseData['courseID'] as int,
//         title: courseData['title'] as String,
//         description: courseData['description'] as String,
//         category: courseData['category'] as String,
//         thumbnailUrl: courseData['thumbnailUrl'] as String,
//         price: (courseData['price'] as num).toDouble(),
//         isPaid: courseData['isPaid'] as bool,
//         courseContents: courseContentsData
//             ?.map((content) =>
//                 CourseContent.fromJson(content as Map<String, dynamic>))
//             .toList(),
//       );
//     } else {
//       // Обработка упрощённого JSON
//       return Course(
//         courseID: json['courseID'] as int,
//         title: json['title'] as String,
//         description: json['description'] as String,
//         category: json['category'] as String,
//         thumbnailUrl: json['thumbnailUrl'] as String,
//         price: (json['price'] as num).toDouble(),
//         isPaid: json['isPaid'] as bool,
//         courseContents: null, // Поле отсутствует в упрощённом JSON
//       );
//     }
//   }

//   Course copyWith({
//     int? courseID,
//     String? title,
//     String? description,
//     String? category,
//     String? thumbnailUrl,
//     double? price,
//     bool? isPaid,
//     List<CourseContent>? courseContents,
//   }) {
//     return Course(
//       courseID: courseID ?? this.courseID,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       category: category ?? this.category,
//       thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
//       price: price ?? this.price,
//       isPaid: isPaid ?? this.isPaid,
//       courseContents: courseContents ?? this.courseContents,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         courseID,
//         title,
//         description,
//         category,
//         thumbnailUrl,
//         price,
//         isPaid,
//         courseContents,
//       ];
// }
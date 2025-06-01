// lib/data/models/course_content.dart

import 'package:equatable/equatable.dart';

class CourseContent extends Equatable {
  final int courseContentID;
  final String title;
  final String description;
  final String url;
  final String photoUrl;

  const CourseContent({
    required this.courseContentID,
    required this.title,
    required this.description,
    required this.url,
    required this.photoUrl,
  });

  factory CourseContent.fromJson(Map<String, dynamic> json) {
    return CourseContent(
      courseContentID: json['courseContentID'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseContentID': courseContentID,
      'title': title,
      'description': description,
      'url': url,
      'photoUrl': photoUrl,
    };
  }

  @override
  List<Object?> get props =>
      [courseContentID, title, description, url, photoUrl];
}

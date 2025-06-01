import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final int id;
  final int courseId;
  final String name;
  final String videoPath;

  const Video({
    required this.id,
    required this.courseId,
    required this.name,
    required this.videoPath,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as int,
      courseId: json['course_id'] as int,
      name: json['name'] as String,
      videoPath: json['video_path'] as String,
    );
  }

  @override
  List<Object?> get props => [id, courseId, name, videoPath];
}
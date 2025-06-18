import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:zavadovskaya_client_app/blocs/courses_detai/course_detail_bloc.dart';
import 'package:zavadovskaya_client_app/data/models/video.dart';
import 'package:zavadovskaya_client_app/presentation/screens/video_player_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseID;

  const CourseDetailScreen({required this.courseID, Key? key}) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final Map<int, Uint8List> _imageCache = {};

  Future<Uint8List> _getImageBytes(int id) async {
    if (_imageCache.containsKey(id)) {
      return _imageCache[id]!;
    }
    final uri = Uri.parse('https://zavadovskayakurs.ru/api/v1/courses/courses/photo/by_course_id/$id');
    final response = await http.get(uri, headers: {"accept": "application/json"}).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      _imageCache[id] = response.bodyBytes;
      return response.bodyBytes;
    } else {
      throw Exception('Ошибка загрузки изображения: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: BlocBuilder<CourseDetailBloc, CourseDetailState>(
        builder: (context, state) {
          if (state is CourseDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CourseDetailLoaded) {
            final course = state.course;
            final videos = state.videos; // Получаем список видео из состояния
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Верхняя часть с изображением курса
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: FutureBuilder<Uint8List>(
                          future: _getImageBytes(course.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                height: 130,
                                width: double.infinity,
                                color: Colors.grey[800],
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            } else if (snapshot.hasError || !snapshot.hasData) {
                              return Container(
                                height: 130,
                                width: double.infinity,
                                color: Colors.grey[800],
                                child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                              );
                            } else {
                              return Image.memory(
                                snapshot.data!,
                                height: 130,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              );
                            }
                          },
                        ),
                      ),
                      Positioned(
                        top: 50,
                        left: 16,
                        child: Material(
                          color: Colors.black45,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      if (course.isPaid)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Куплен',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Описание курса
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C3E),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            course.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[300],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (!course.isPaid)
                            Text(
                              'Цена: ${course.cost.toStringAsFixed(2)} ₽',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purpleAccent,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Заголовок списка видео
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Список видео (${videos.length}):',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  // Видео карточки
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      return VideoCard(
                        video: video,
                        isCoursePaid: course.isPaid,
                        coursePrice: course.cost,
                        courseId: course.id,
                        video_id: video.id,
                      );
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          } else if (state is CourseDetailError) {
            return Center(
              child: Text(
                'Ошибка: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return Container();
        },
      ),

      bottomNavigationBar: BlocBuilder<CourseDetailBloc, CourseDetailState>(
        builder: (context, state) {
          if (state is CourseDetailLoaded && !state.course.isPaid) {
            final course = state.course;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/payment',
                      arguments: {'courseID': course.id, 'price': course.cost},
                    );
                  },
                  child: const Text(
                    'Оплатить курс',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final Video video;
  final bool isCoursePaid;
  final double coursePrice;
  final int courseId;
  final int video_id;

  const VideoCard({
    required this.video,
    required this.isCoursePaid,
    required this.coursePrice,
    required this.courseId,
    required this.video_id,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: const Color(0xFF2C2C3E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.purple, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          if (!isCoursePaid) {
            _showPaymentDialog(context);
          } else {
            _openVideoPlayer(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.play_arrow, size: 30, color: Colors.purple),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (!isCoursePaid)
                      Text(
                        'Доступно после оплаты курса',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C3E),
          title: const Text('Доступ ограничен', style: TextStyle(color: Colors.white)),
          content: Text(
            'Для просмотра видео "${video.name}" необходимо оплатить курс за ${coursePrice.toStringAsFixed(2)} ₽.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена', style: TextStyle(color: Colors.purple)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () {Navigator.of(context).pop();
                Navigator.pushNamed(
                  context,
                  '/payment',
                  arguments: {'courseID': courseId, 'price': coursePrice},
                );
              },
              child: const Text('Оплатить'),
            ),
          ],
        );
      },
    );
  }

  void _openVideoPlayer(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => VideoPlayerWidget(
        videoId: video.id,
      ),
    ),
  );
}

}
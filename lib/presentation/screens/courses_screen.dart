import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as secureStorage;
import 'package:http/http.dart' as http;
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/courses/courses_bloc.dart';
import '../../data/repositories/course_repository.dart';

class CoursesScreen extends StatefulWidget {
  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final ScrollController _scrollController = ScrollController();
  int _highlightedCategoryIndex = 0;
  List<String> _categories = [];
  final Map<String, GlobalKey> _categoryKeys = {};

   // Добавляем кеш для изображений: ключ — id курса, значение — байты изображения
  final Map<int, Uint8List> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

@override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCategory(int index) {
    if (index >= 0 && index < _categories.length) {
      final key = 'category_$index';
      final contextKey = _categoryKeys[key];
      if (contextKey != null && contextKey.currentContext != null) {
        Scrollable.ensureVisible(
          contextKey.currentContext!,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    }
  }

   Future<Uint8List> _getImageBytes(int id) async {
    if (_imageCache.containsKey(id)) {
      // Если есть в кеше — возвращаем сразу
      return _imageCache[id]!;
    }
    final uri = Uri.parse('https://zavadovskayakurs.ru/api/v1/courses/courses/photo/by_course_id/$id');
    final response = await http.get(uri, headers: {"accept": "application/json"}).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      _imageCache[id] = response.bodyBytes; // Сохраняем в кеш
      return response.bodyBytes;
    } else {
      throw Exception('Ошибка загрузки изображения: ${response.statusCode}');
    }
  }

  void _onScroll() {
    int? newHighlightedIndex;
    double minDistance = double.infinity;

    for (int i = 0; i < _categories.length; i++) {
      final key = _categoryKeys['category_$i'];
      if (key != null && key.currentContext != null) {
        final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero).dy;

        final distanceFromTop = position.abs();
        if (distanceFromTop < minDistance) {
          minDistance = distanceFromTop;
          newHighlightedIndex = i;
        }
      }
    }

    if (newHighlightedIndex != null && newHighlightedIndex != _highlightedCategoryIndex) {
      setState(() {
        _highlightedCategoryIndex = newHighlightedIndex!;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (context) =>
        CoursesBloc(courseRepository: context.read<CourseRepository>())
          ..add(GetAllCoursesRequested()),
    child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 10,
        toolbarHeight: 70,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        title: const Text(
          'Каталог курсов',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //   child: Tooltip(
          //     message: "Профиль",
          //     child: GestureDetector(
          //       onTap: () => Navigator.pushNamed(context, '/profile'),
          //       child: const CircleAvatar(
          //         backgroundColor: Colors.white24,
          //         child: Icon(Icons.person, color: Colors.white),
          //       ),
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Tooltip(
              message: "Выйти",
              child: GestureDetector(
                onTap: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                },
                child: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.logout, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CoursesBloc, CoursesState>(
        builder: (context, state) {
          if (state is CoursesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CoursesLoaded) {
            final groupedCourses = state.groupedCourses;
            _categories = groupedCourses.keys.toList();

            for (int i = 0; i < _categories.length; i++) {
              final key = 'category_$i';
              if (!_categoryKeys.containsKey(key)) {
                _categoryKeys[key] = GlobalKey();
              }
            }

            return Column(
              children: [
                Container(
                  height: 65,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isHighlighted = _highlightedCategoryIndex == index;
                      return GestureDetector(
                        onTap: () => _scrollToCategory(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: isHighlighted ? null : Colors.transparent,
                            gradient: isHighlighted
                                ? const LinearGradient(
                                    colors: [Colors.deepPurple, Colors.purpleAccent],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            border: isHighlighted ? Border.all(color: Colors.purple, width: 2) : null,
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      for (int i = 0; i < _categories.length; i++) ...[
                        SliverToBoxAdapter(
                          child: Container(
                            key: _categoryKeys['category_$i'],
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              _categories[i],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 2 / 3,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final course = groupedCourses[_categories[i]]![index];
                                return Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  elevation: 6,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/courseDetail',
                                        arguments: course.id,
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E1E2C),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3), width: 1),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
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
                                              if (course.isPaid)
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.withOpacity(0.85),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Text(
                                                      'Куплен',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                                            child: Text(
                                              course.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            child: Text(
                                              course.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12),
                                                  gradient: course.isPaid
                                                      ? null
                                                      : const LinearGradient(
                                                          colors: [Colors.deepPurple, Colors.purpleAccent],
                                                        ),
                                                  color: course.isPaid ? Colors.grey[700] : null,
                                                ),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/courseDetail',
                                                      arguments: course.id,
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    shadowColor: Colors.transparent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                  ),
                                                  child: Text(
                                                    course.isPaid ? 'Куплен' : '${course.cost.toStringAsFixed(2)} ₽',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: groupedCourses[_categories[i]]!.length,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          } else if (state is CoursesError) {
            return Center(child: Text('Ошибка: ${state.error}'));
          }
          return Container();
        },
      ),
    ),
  );
}
}
// // lib/presentation/screens/create_course_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../blocs/courses/courses_bloc.dart';
// import '../../data/models/course.dart';

// class CreateCourseScreen extends StatefulWidget {
//   @override
//   State<CreateCourseScreen> createState() => _CreateCourseScreenState();
// }

// class _CreateCourseScreenState extends State<CreateCourseScreen> {
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController thumbnailUrlController = TextEditingController();
//   final TextEditingController categoryController = TextEditingController();
//   final TextEditingController priceController = TextEditingController();

//   void _onCreateCoursePressed() {
//     final title = titleController.text.trim();
//     final description = descriptionController.text.trim();
//     final thumbnailUrl = thumbnailUrlController.text.trim();
//     final category = categoryController.text.trim();
//     final price = double.tryParse(priceController.text.trim()) ?? 0.0;

//     if (title.isEmpty || description.isEmpty || thumbnailUrl.isEmpty || category.isEmpty || price <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Пожалуйста, заполните все поля корректно')),
//       );
//       return;
//     }

//     final course = Course(
//       courseID: 0, // Сервер сам назначит ID
//       title: title,
//       description: description,
//       category: category,
//       thumbnailUrl: thumbnailUrl,
//       price: price,
//       isPaid: false, // По умолчанию
//     );

//     BlocProvider.of<CoursesBloc>(context).add(CreateCourseRequested(course: course));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Создать курс'),
//         ),
//         body: BlocListener<CoursesBloc, CoursesState>(
//           listener: (context, state) {
//             if (state is CourseCreated) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Курс успешно создан')),
//               );
//               Navigator.pop(context); // Вернуться на предыдущий экран
//             }
//             if (state is CoursesError) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text(state.error)),
//               );
//             }
//           },
//           child: Padding(
//             padding: EdgeInsets.all(16.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: titleController,
//                     decoration: InputDecoration(labelText: 'Название курса'),
//                   ),
//                   TextField(
//                     controller: descriptionController,
//                     decoration: InputDecoration(labelText: 'Описание курса'),
//                   ),
//                   TextField(
//                     controller: thumbnailUrlController,
//                     decoration: InputDecoration(labelText: 'URL изображения'),
//                   ),
//                   TextField(
//                     controller: categoryController,
//                     decoration: InputDecoration(labelText: 'Категория'),
//                   ),
//                   TextField(
//                     controller: priceController,
//                     decoration: InputDecoration(labelText: 'Цена'),
//                     keyboardType: TextInputType.numberWithOptions(decimal: true),
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _onCreateCoursePressed,
//                     child: Text('Создать курс'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ));
//   }
// }
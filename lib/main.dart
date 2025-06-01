// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zavadovskaya_client_app/blocs/courses_detai/course_detail_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/courses/courses_bloc.dart';
import 'blocs/profile/profile_bloc.dart';
import 'blocs/payment/payment_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/course_repository.dart';
import 'data/repositories/course_repository_impl.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/repositories/payment_repository.dart';
import 'data/repositories/payment_repository_impl.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/courses_screen.dart';
import 'presentation/screens/course_detail_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/video_player_screen.dart';
import 'presentation/screens/payment_screen.dart';
import 'presentation/screens/payment_confirmation_screen.dart';
import 'presentation/screens/create_course_screen.dart';
import 'config.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Получение baseUrl из Config
  final String baseUrl = Config.baseUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>(
            create: (_) => AuthRepositoryImpl(baseUrl: baseUrl),
          ),
          RepositoryProvider<CourseRepository>(
            create: (_) => CourseRepositoryImpl(
              baseUrl: baseUrl,
            ),
          ),
          RepositoryProvider<ProfileRepository>(
            create: (context) => ProfileRepositoryImpl(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          RepositoryProvider<PaymentRepository>(
            create: (_) => PaymentRepositoryImpl(
              baseUrl: baseUrl,
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) =>
                  AuthBloc(authRepository: context.read<AuthRepository>())
                    ..add(AppStarted()),
            ),
            BlocProvider<CoursesBloc>(
              create: (context) => CoursesBloc(
                  courseRepository: context.read<CourseRepository>()),
            ),
            BlocProvider<ProfileBloc>(
              create: (context) => ProfileBloc(
                  profileRepository: context.read<ProfileRepository>()),
            ),
            BlocProvider<PaymentBloc>(
              create: (context) => PaymentBloc(
                paymentRepository: context.read<PaymentRepository>(),
                authRepository: context.read<AuthRepository>(),
              ),
            ),
          ],
          child: MaterialApp(
            title: 'Онлайн Курсы',
            theme: ThemeData(
              brightness:
                  Brightness.dark, // Устанавливаем темную тему по умолчанию
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) {
                return BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return CoursesScreen();
                    } else if (state is AuthUnauthenticated) {
                      return LoginScreen();
                    } else {
                      return Scaffold(
                          body: Center(child: CircularProgressIndicator()));
                    }
                  },
                );
              },
              '/home': (context) => CoursesScreen(),
              '/profile': (context) {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  return ProfileScreen();
                }
                return LoginScreen();
              },
              '/courseDetail': (context) {
                print('1');
                final courseID =
                    ModalRoute.of(context)!.settings.arguments as int;
                    print('2');
                return BlocProvider(
                  create: (context) => CourseDetailBloc(
                    courseRepository: context.read<CourseRepository>(),
                  )..add(GetCourseDetailRequested(courseID: courseID)),
                  child: CourseDetailScreen(courseID: courseID),
                );
              },
                '/videoPlayer': (context) {
                  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                  final videoId = args['videoId'] as int;
                  final lessonTitle = args['name']?.toString() ?? 'Без названия';
                
                  return VideoPlayerScreen(
                    videoTitle: lessonTitle,
                    videoId: videoId,
                  );
                },
              '/payment': (context) {
                final args = ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
                final courseID = args['courseID'] as int;
                final coursePrice = args['price'] as double;

                return PaymentScreen(
                    courseID: courseID, coursePrice: coursePrice);
              },
              // '/createCourse': (context) => CreateCourseScreen(),
              // Добавьте другие маршруты при необходимости
            },
          ),
        ),
      ),
    );
  }
}

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
  final String baseUrl = Config.baseUrl;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(baseUrl: baseUrl),
        ),
        RepositoryProvider<CourseRepository>(
          create: (_) => CourseRepositoryImpl(baseUrl: baseUrl),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepositoryImpl(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        RepositoryProvider<PaymentRepository>(
          create: (_) => PaymentRepositoryImpl(baseUrl: baseUrl),
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
            create: (context) =>
                CoursesBloc(courseRepository: context.read<CourseRepository>()),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) =>
                ProfileBloc(profileRepository: context.read<ProfileRepository>()),
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
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          onGenerateRoute: _generateRoute,
          home: BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthFailure && state.error.isNotEmpty) {
      Future.microtask(() {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Ошибка входа'),
              content: const Text('Неправильный логин или пароль.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ОК'),
                ),
              ],
            ),
          );
        }
      });
    }
  },
  builder: (context, state) {
    if (state is AuthAuthenticated) {
      return CoursesScreen();
    } else if (state is AuthUnauthenticated || state is AuthFailure) {
      return LoginScreen();
    } else {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
  },
),

        ),
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => CoursesScreen());

      case '/profile':
        return MaterialPageRoute(
          builder: (context) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              return ProfileScreen();
            }
            return LoginScreen();
          },
        );

      case '/courseDetail':
        final courseID = settings.arguments as int;
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => CourseDetailBloc(
              courseRepository: context.read<CourseRepository>(),
            )..add(GetCourseDetailRequested(courseID: courseID)),
            child: CourseDetailScreen(courseID: courseID),
          ),
        );

      case '/videoPlayer':
        final args = settings.arguments as Map<String, dynamic>;
        final videoId = args['videoId'] as int;
        final lessonTitle = args['name']?.toString() ?? 'Без названия';
        return MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(
            videoTitle: lessonTitle,
            videoId: videoId,
          ),
        );

      case '/payment':
        final args = settings.arguments as Map<String, dynamic>;
        final courseID = args['courseID'] as int;
        final coursePrice = args['price'] as double;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(
            courseID: courseID,
            coursePrice: coursePrice,
          ),
        );

      // Пример добавления экрана создания курса
      // case '/createCourse':
      //   return MaterialPageRoute(builder: (_) => CreateCourseScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Неизвестный маршрут: ${settings.name}')),
          ),
        );
    }
  }
}

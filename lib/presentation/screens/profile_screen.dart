import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zavadovskaya_client_app/data/repositories/profile_repository.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        profileRepository: RepositoryProvider.of<ProfileRepository>(context),
      )..add(LoadProfile()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Профиль'),
          backgroundColor: Colors.purple,
          elevation: 0,
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return Center(child: CircularProgressIndicator(color: Colors.purple));
            } else if (state is ProfileLoaded) {
              final user = state.user;

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade800, Colors.purple.shade400],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: user.photoPath.isNotEmpty
                              ? NetworkImage(user.photoPath)
                              : null,
                          backgroundColor: Colors.white24,
                          child: user.photoPath.isEmpty
                              ? Icon(Icons.person, size: 60, color: Colors.white)
                              : null,
                        ),
                        SizedBox(height: 20),
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          user.phone,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 30),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Купленные курсы:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: user.purchasedCourseIds.isEmpty
                              ? Center(
                                  child: Text(
                                    'Нет купленных курсов.',
                                    style: TextStyle(color: Colors.white70, fontSize: 16),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: user.purchasedCourseIds.length,
                                  itemBuilder: (context, index) {
                                    final courseID = user.purchasedCourseIds[index];
                                    return Card(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      child: ListTile(
                                        leading: Icon(Icons.play_circle_fill, color: Colors.white),
                                        title: Text(
                                          'Курс ID: $courseID',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                        ),
                                        subtitle: Text(
                                          'Описание курса (при необходимости)',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is ProfileError) {
              return Center(
                child: Text(
                  'Ошибка: ${state.error}',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }
            return Center(
              child: Text(
                'Пользователь не авторизован',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          },
        ),
      ),
    );
  }
}

// lib/blocs/auth/auth_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegistrationRequested>(_onRegistrationRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SendSmsCode>(_onSendSmsCode);
    // on<SubmitSmsCode>(_onSubmitSmsCode);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await authRepository.getCurrentUser();
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.login(event.email, event.password);
      final user = await authRepository.getCurrentUser();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onRegistrationRequested(RegistrationRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.registration(event.name, event.phone, event.email, event.password);
      final user = await authRepository.getCurrentUser();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }
  
}


  Future<void> _onSendSmsCode(SendSmsCode event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  await Future.delayed(Duration(seconds: 1)); // Заглушка для отправки SMS
  emit(SmsCodeSent()); // Отправляем состояние, что код выслан
}

// Future<void> _onSubmitSmsCode(SubmitSmsCode event, Emitter<AuthState> emit) async {
//   emit(AuthLoading());
//   await Future.delayed(Duration(seconds: 1)); // Эмуляция обработки кода
//   emit(AuthAuthenticated(user: User(id: '123', email: "test@mail", name: "test", phone: '', login: '', avatar: '', purchasedCourseIds: []))); // Заглушка
// }


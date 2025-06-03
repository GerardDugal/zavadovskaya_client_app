// lib/blocs/auth/auth_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zavadovskaya_client_app/config.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  // Сохраняем последние данные логина для повторной попытки
  String? _lastEmail;
  String? _lastPassword;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegistrationRequested>(_onRegistrationRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SendSmsCode>(_onSendSmsCode);
    // on<SubmitSmsCode>(_onSubmitSmsCode);
    on<RetryLoginRequested>(_onRetryLoginRequested);
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
  Config.mprint('AuthBloc: _onLoginRequested, email: ${event.email}');
  emit(AuthLoading());
  Config.mprint('AuthBloc: состояние AuthLoading эмитировано');

  _lastEmail = event.email;
  _lastPassword = event.password;

  try {
    final result = await authRepository.login(event.email, event.password);
    Config.mprint('AuthBloc: login успешно, результат: $result');

    final user = await authRepository.getCurrentUser();
    Config.mprint('AuthBloc: пользователь получен: $user');

    emit(AuthAuthenticated(user: user));
    Config.mprint('AuthBloc: состояние AuthAuthenticated эмитировано');
  } catch (e) {
    Config.mprint('AuthBloc: ошибка при логине: $e');
    emit(AuthFailure(error: e.toString()));
    Config.mprint('AuthBloc: состояние AuthFailure эмитировано');
  }
}


  Future<void> _onRetryLoginRequested(RetryLoginRequested event, Emitter<AuthState> emit) async {
    if (_lastEmail == null || _lastPassword == null) {
      emit(AuthFailure(error: "Повторный вход невозможен: отсутствуют данные."));
      return;
    }

    emit(AuthLoading());

    try {
      await authRepository.login(_lastEmail!, _lastPassword!);
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

  Future<void> _onSendSmsCode(SendSmsCode event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(Duration(seconds: 1)); // Заглушка
    emit(SmsCodeSent());
  }

  // Добавьте этот метод при необходимости:
  // Future<void> _onSubmitSmsCode(...) async { ... }
}

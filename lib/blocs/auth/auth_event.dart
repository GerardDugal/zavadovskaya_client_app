// lib/blocs/auth/auth_event.dart

part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RetryLoginRequested extends AuthEvent {}

class RegistrationRequested extends AuthEvent {
  final String name;
  final String phone;
  final String email;
  final String password;

  const RegistrationRequested({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, phone, email, password];
}

class LogoutRequested extends AuthEvent {}

abstract class VerifySmsCodeEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class SendSmsCode extends AuthEvent {
  final String phoneNumber;

  SendSmsCode({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class SubmitSmsCode extends AuthEvent {
  final String phoneNumber;
  final String code;

  SubmitSmsCode({required this.phoneNumber, required this.code});

  @override
  List<Object?> get props => [phoneNumber, code];
}

// class PasswordRecovery extends AuthEvent {
//   final String login;

//   const PasswordRecovery({required this.login});

//   @override
//   List<Object?> get props => [login];
// }
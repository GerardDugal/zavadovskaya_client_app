// lib/blocs/auth/auth_state.dart

part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

abstract class VerifySmsCodeState extends Equatable {
  @override
  List<Object> get props => [];
}

class VerifySmsCodeInitial extends VerifySmsCodeState {}

class VerifySmsCodeLoading extends VerifySmsCodeState {}

class VerifySmsCodeSuccess extends VerifySmsCodeState {}

class VerifySmsCodeFailure extends VerifySmsCodeState {
  final String error;

  VerifySmsCodeFailure({required this.error});

  @override
  List<Object> get props => [error];
}

// Добавляем состояние отправки SMS
class SmsCodeSent extends AuthState {}

// class RecoveryPassword extends AuthState {
//   final bool recovery;

//   const RecoveryPassword({required this.recovery});

//   @override
//   List<Object?> get props => [recovery];
// }
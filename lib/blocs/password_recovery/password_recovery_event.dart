// lib/blocs/auth/auth_event.dart

part of 'password_recovery_bloc.dart';

abstract class PasswordRecoveryEvent extends Equatable {
  const PasswordRecoveryEvent();
  
  @override
  List<Object?> get props => [];
}

class PasswordRecovery extends PasswordRecoveryEvent {
  final String login;

  const PasswordRecovery({required this.login});

  @override
  List<Object?> get props => [login];
}
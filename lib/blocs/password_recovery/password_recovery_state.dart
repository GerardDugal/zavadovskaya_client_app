// lib/blocs/auth/auth_state.dart

part of 'password_recovery_bloc.dart';

abstract class PasswordRecoveryState extends Equatable {
  const PasswordRecoveryState();
  
  @override
  List<Object?> get props => [];
}

class PasswordRecoveryInitial extends PasswordRecoveryState {}

class RecoveryPassword extends PasswordRecoveryState {
  final bool recovery;

  const RecoveryPassword({required this.recovery});

  @override
  List<Object?> get props => [recovery];
}
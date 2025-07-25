// lib/blocs/profile/profile_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/user.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;

  const ProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String error;

  const ProfileError({required this.error});

  @override
  List<Object?> get props => [error];
}
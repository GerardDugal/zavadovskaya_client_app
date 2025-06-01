// lib/blocs/profile/profile_bloc.dart

import 'package:bloc/bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/models/user.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final User user = await profileRepository.getUserProfile();
      emit(ProfileLoaded(user: user));
    } catch (e) {
      emit(ProfileError(error: e.toString()));
    }
  }
}
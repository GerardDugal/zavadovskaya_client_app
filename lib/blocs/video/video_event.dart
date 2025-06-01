part of 'video_bloc.dart';

abstract class VideoEvent {}

class LoadVideoEvent extends VideoEvent {
  final int videoId;

  LoadVideoEvent(this.videoId);
}

class PlayVideoEvent extends VideoEvent {}

class PauseVideoEvent extends VideoEvent {}

class DisposeVideoEvent extends VideoEvent {}
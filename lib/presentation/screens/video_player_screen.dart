import 'dart:io' as io show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:zavadovskaya_client_app/blocs/video/video_bloc.dart';
import 'package:zavadovskaya_client_app/data/repositories/course_repository.dart';

class VideoPlayerWidget extends StatelessWidget {
  final int videoId;
  final bool autoPlay;

  const VideoPlayerWidget({
    Key? key,
    required this.videoId,
    this.autoPlay = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoBloc(context.read<CourseRepository>())
        ..add(LoadVideoEvent(videoId, autoPlay: autoPlay)),
      child: BlocBuilder<VideoBloc, VideoState>(
        builder: (context, state) {
          return _buildVideoPlayer(context, state);
        },
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context, VideoState state) {
    if (state is VideoInitial || state is VideoLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state is VideoError) {
      return Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки видео',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  color: Colors.blue,
                  onPressed: () =>
                      context.read<VideoBloc>().add(LoadVideoEvent(videoId)),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
          _buildBackButton(context),
        ],
      );
    }

    if (state is VideoReady) {
  final chewieController = state.chewieController!;
  final hasAudio = state.hasAudio ?? true;

  return WillPopScope(
    onWillPop: () async {
      if (chewieController.isFullScreen) {
        chewieController.exitFullScreen();
        return false;
      }
      return true;
    },
    child: Stack(
      children: [
        // Основной контейнер для видео
        Container(
          color: Colors.black, // Фон на случай черных полос
          child: Center(
            child: SizedBox(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: chewieController
                    .videoPlayerController.value.aspectRatio,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    platform: TargetPlatform.iOS,
                  ),
                  child: Chewie(
                    controller: chewieController,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Предупреждение об отсутствии звука
        if (!hasAudio)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.amber.withOpacity(0.8),
              child: const Text(
                'Видео не содержит звуковой дорожки',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        
        // Кнопка "Назад" только вне полноэкранного режима
        if (!chewieController.isFullScreen)
          _buildBackButton(context),
      ],
    ),
  );
}

    return const SizedBox.shrink();
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: 50,
      left: 16,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.5),
        child: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}

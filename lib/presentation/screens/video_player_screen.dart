import 'package:flutter/material.dart';
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
      return const Center(child: CircularProgressIndicator());
    }

    if (state is VideoError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Positioned(
                        top: 50,
                        left: 16,
                        child: Material(
                          color: Colors.black45,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки видео',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<VideoBloc>().add(LoadVideoEvent(videoId)),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (state is VideoReady) {
      return Column(
        children: [
          Expanded(
            child: Chewie(controller: state.chewieController!),
          ),
          if (!state.hasAudio!)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.amber,
              child: const Text(
                'Видео не содержит звуковой дорожки',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
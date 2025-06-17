import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:zavadovskaya_client_app/blocs/video/video_bloc.dart';
import 'package:zavadovskaya_client_app/data/repositories/course_repository.dart';

class VideoPlayerScreen extends StatelessWidget {
  final int videoId;
  final String videoTitle;

  const VideoPlayerScreen({
    required this.videoId,
    required this.videoTitle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(videoTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocProvider(
          create: (context) =>
              VideoBloc(context.read<CourseRepository>())..add(LoadVideoEvent(videoId)),
          child: const _VideoPlayerContent(),
        ),
      ),
    );
  }
}

class _VideoPlayerContent extends StatelessWidget {
  const _VideoPlayerContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoBloc, VideoState>(
      listener: (context, state) {
        if (state is VideoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is VideoLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is VideoError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 16),
                Text('Ошибка: ${state.message}'),
              ],
            ),
          );
        }

        if (state.controller != null) {
          return _CustomVideoControls(
            controller: state.controller!,
          );
        }

        return const SizedBox();
      },
    );
  }
}

class _CustomVideoControls extends StatefulWidget {
  final VideoPlayerController controller;

  const _CustomVideoControls({
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<_CustomVideoControls> createState() => _CustomVideoControlsState();
}

class _CustomVideoControlsState extends State<_CustomVideoControls> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(() => setState(() {}));
    _controller.initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(_controller),
              _PlayPauseOverlay(controller: _controller),
              _ProgressBar(controller: _controller),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _PlayPauseOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      child: Center(
        child: controller.value.isPlaying
            ? const SizedBox()
            : Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 48),
                ),
              ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final VideoPlayerController controller;

  const _ProgressBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final duration = controller.value.duration;
    final position = controller.value.position;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          min: 0,
          max: duration.inMilliseconds.toDouble(),
          value: position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
          onChanged: (value) {
            controller.seekTo(Duration(milliseconds: value.toInt()));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatTime(position), style: const TextStyle(color: Colors.white)),
              Text(_formatTime(duration), style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

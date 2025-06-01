import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    onWillPop: () async {
      // Здесь можно добавить дополнительную логику при выходе
      return true; // true — разрешить выход
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(videoTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Возврат назад
          },
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
                const SizedBox(height: 20),
              ],
            ),
          );
        }

        if (state.controller != null) {
          return _VideoControls(
            controller: state.controller!,
            isPlaying: state is VideoPlaying,
          );
        }

        return Container();
      },
    );
  }
}

class _VideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isPlaying;

  const _VideoControls({
    required this.controller,
    required this.isPlaying,
    Key? key,
  }) : super(key: key);

  @override
  __VideoControlsState createState() => __VideoControlsState();
}

class __VideoControlsState extends State<_VideoControls> {
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      videoPlayerController: widget.controller,
      autoPlay: widget.isPlaying,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControlsOnInitialize: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.purple,
        handleColor: Colors.purpleAccent,
        bufferedColor: Colors.grey[300]!,
        backgroundColor: Colors.grey[600]!,
      ),
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.purple),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _VideoControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _chewieController.dispose();
      _chewieController = ChewieController(
        videoPlayerController: widget.controller,
        autoPlay: widget.isPlaying,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.purple,
          handleColor: Colors.purpleAccent,
          bufferedColor: Colors.grey[300]!,
          backgroundColor: Colors.grey[600]!,
        ),
      );
    }
  }

  @override
  void dispose() {
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(controller: _chewieController);
  }
}
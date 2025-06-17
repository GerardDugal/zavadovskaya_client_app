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
    return Scaffold(
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
    );
  }
}

class _VideoPlayerContent extends StatefulWidget {
  const _VideoPlayerContent({Key? key}) : super(key: key);

  @override
  State<_VideoPlayerContent> createState() => _VideoPlayerContentState();
}

class _VideoPlayerContentState extends State<_VideoPlayerContent> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  late VideoBloc _videoBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _videoBloc = context.read<VideoBloc>();
    _videoBloc.stream.listen((state) async {
      if (state.controller != null) {
        await _controller?.dispose();
        _controller = state.controller;
        await _controller!.initialize();
        setState(() {
          _isInitialized = true;
          _isPlaying = _controller!.value.isPlaying;
        });
        _controller!.addListener(() {
          setState(() {
            _isPlaying = _controller!.value.isPlaying;
          });
        });
      }
      if (state is VideoError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller!),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                    } else {
                      _controller!.play();
                    }
                  });
                },
                child: !_isPlaying
                    ? Container(
                        color: Colors.black45,
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 64),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        VideoProgressIndicator(
          _controller!,
          allowScrubbing: true,
          colors: VideoProgressColors(
            playedColor: Colors.purple,
            bufferedColor: Colors.purpleAccent.withOpacity(0.5),
            backgroundColor: Colors.grey,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';


class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final String _authToken;
  late final String _videoUrl;
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasAudio = true;

  @override
  void initState() {
    super.initState();
    _authToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c3IiOjEsImV4cCI6MTc1MDMyMzkxMX0.clIueVNSAKaWxAwnMtnG2iCL0RBnT5WrmMcFP_sZ1gU";
    _videoUrl = "https://zavadovskayakurs.ru/api/v1/stream/web_stream/by_id/10?token=$_authToken";
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 1. Проверка наличия аудио в видео
      await _checkVideoAudio();

      // 2. Инициализация видеоконтроллера
      _videoController = VideoPlayerController.network(
        _videoUrl,
        httpHeaders: {'Authorization': 'Bearer $_authToken'},
              );

      await _videoController.initialize();

      // 3. Установка громкости на максимум
      await _videoController.setVolume(1.0);

      // 4. Инициализация ChewieController
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowedScreenSleep: false,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.withOpacity(0.5),
        ),
        placeholder: Container(color: Colors.black),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      debugPrint('Video initialization error: $e');
    }
  }

  Future<void> _checkVideoAudio() async {
    try {
      // Здесь можно добавить проверку метаданных видео
      // Например, через FFprobe или анализ заголовков
      setState(() {
        _hasAudio = true; // Временная заглушка
      });
    } catch (e) {
      debugPrint('Audio check error: $e');
      setState(() {
        _hasAudio = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Видео плеер'),
        centerTitle: true,
        actions: [
          if (!_isLoading && _hasAudio)
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () async {
                await _videoController.setVolume(1.0);
                setState(() {});
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }
return Column(
      children: [
        Expanded(child: Chewie(controller: _chewieController!)),
        if (!_hasAudio)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.amber,
            child: const Text(
              'Видео не содержит звуковой дорожки',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 20),
          const Text(
            "Ошибка загрузки видео",
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _initVideoPlayer,
            child: const Text("Повторить попытку"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
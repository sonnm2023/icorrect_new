import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class DoingTestScreen extends StatelessWidget {
  final List<String> videoPaths;
  final int currentIndex;

  const DoingTestScreen(
      {super.key, required this.videoPaths, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoRecordingProvider(videoPaths),
      child: const Scaffold(
        body: QuestionWidget(),
      ),
    );
  }
}

class QuestionWidget extends StatelessWidget {
  const QuestionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        _buildVideoPlayerContainer(context),
        const RecordView(),
      ],
    );
  }

  Widget _buildVideoPlayerContainer(BuildContext context) {
    return Consumer<VideoRecordingProvider>(
        builder: (context, provider, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 230,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg_test_room.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: provider.isReady
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoPlayer(provider.videoPlayerController!),
                  )
                : const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(),
                    ),
                  ),
          ),
          //Question list
          Expanded(
            child: const SizedBox(
              child: Text("Question list"),
            ),
          ),
        ],
      );
    });
  }
}

class RecordView extends StatelessWidget {
  const RecordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoRecordingProvider>(
      builder: (context, provider, child) {
        return Visibility(
          visible: provider.showRecordView,
          child: Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 300,
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Recording...',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${provider.timerSeconds}',
                      style: const TextStyle(color: Colors.white, fontSize: 36),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class VideoRecordingProvider with ChangeNotifier {
  VideoPlayerController? _videoPlayerController;
  bool _showRecordView = false;
  int _timerSeconds = 20; // Số giây của timer đếm ngược
  Timer? _timer;
  int _currentIndex =
      0; // Thêm biến currentIndex để lưu trạng thái của câu hỏi hiện tại
  final List<String> _videoPaths; // Danh sách các đường dẫn video câu hỏi

  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  bool get showRecordView => _showRecordView;
  void setShowRecordView(bool value) {
    _showRecordView = value;
    notifyListeners();
  }

  void resetShowRecordView() {
    _showRecordView = false;
  }

  int get timerSeconds => _timerSeconds;

  int get currentIndex => _currentIndex; // Getter để lấy currentIndex

  bool _isReady = false;
  bool get isReady => _isReady;
  void setIsReady(bool value) {
    _isReady = value;
    notifyListeners();
  }

  void resetIsReady() {
    _isReady = false;
  }

  VideoRecordingProvider(this._videoPaths) {
    String videoPath = _videoPaths[_currentIndex];
    File videoFile = File(videoPath);

    // Khởi tạo VideoPlayerController từ tệp cục bộ
    _videoPlayerController = VideoPlayerController.file(videoFile);
    _timer = Timer(const Duration(), () {});

    _playNextQuestion();
  }

  Future<void> _playNextQuestion() async {
    if (_currentIndex < _videoPaths.length) {
      // Lấy đường dẫn của video từ danh sách
      String videoPath = _videoPaths[_currentIndex];
      File videoFile = File(videoPath);

      // Khởi tạo VideoPlayerController từ tệp cục bộ
      _videoPlayerController = VideoPlayerController.file(videoFile);

      await _videoPlayerController!.initialize();
      // Thêm lắng nghe sự kiện khi video đã phát xong
      _videoPlayerController!.addListener(_onVideoPlayerStateChanged);
      // Bắt đầu phát video
      if (_currentIndex == 0) {
        setIsReady(true);
        _videoPlayerController!.play();
      } else {
        _videoPlayerController!.play();
      }
    } else {
      // Nếu đã phát hết danh sách video, không làm gì cả
      print("Đã phát hết danh sách video");
    }
  }

  void _onVideoPlayerStateChanged() {
    // if (_videoPlayerController!.value.isPlaying &&
    if (_videoPlayerController!.value.position ==
        _videoPlayerController!.value.duration) {
      // Bắt đầu đếm ngược
      _startCountdown();
      setShowRecordView(true);
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        _timerSeconds--;
        notifyListeners();
      } else {
        // Đếm ngược về 0, dừng ghi âm và chuyển sang câu hỏi tiếp theo
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    // Dừng ghi âm
    _showRecordView = false;
    _timer!.cancel(); // Dừng timer
    _timerSeconds = 20; // Reset timer
    _currentIndex++; // Cập nhật currentIndex để chuyển sang câu hỏi tiếp theo
    notifyListeners();
    // Chuyển sang câu hỏi tiếp theo
    _videoPlayerController!.pause(); // Dừng video hiện tại
    _playNextQuestion();
  }

  @override
  void dispose() {
    _videoPlayerController!.dispose();
    _timer!.cancel();
    super.dispose();
  }
}

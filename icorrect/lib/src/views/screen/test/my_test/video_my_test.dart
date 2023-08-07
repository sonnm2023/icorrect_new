import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/app_color.dart';
import '../../../../provider/my_test_provider.dart';
import '../../../widget/default_text.dart';

class VideoMyTest extends StatefulWidget {
  const VideoMyTest({super.key});

  @override
  State<VideoMyTest> createState() => _VideoMyTestState();
}

class _VideoMyTestState extends State<VideoMyTest> {
  VideoPlayerController? _playerController;

  @override
  void initState() {
    super.initState();
    _playerController = VideoPlayerController.networkUrl(Uri.parse(
        "https://icorrect-audio.s3.ap-southeast-1.amazonaws.com/309.mp4"))
      ..initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyTestProvider>(builder: (context, provider, child) {
      _playerController!.addListener(() {
        if (!_playerController!.value.size.isEmpty) {
          if (_playerController!.value.position ==
              _playerController!.value.duration) {
            provider.setSampleAudioPlaying(!provider.isSamplePlaying);
          }
        }
      });
      return Container(
          alignment: Alignment.center,
          child: Stack(
            children: [
              InkWell(
                  onTap: () {
                    provider.setSampleAudioPlaying(!provider.isSamplePlaying);
                    _playerController!.pause();
                  },
                  child: SizedBox(
                      height: double.infinity,
                      child: AspectRatio(
                          aspectRatio: _playerController!.value.aspectRatio,
                          child: VideoPlayer(_playerController!)))),
              Visibility(
                visible: !provider.isSamplePlaying,
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: const Color.fromARGB(153, 86, 86, 86),
                  child: InkWell(
                    onTap: () {
                      provider.setSampleAudioPlaying(!provider.isSamplePlaying);
                      _playerController!.play();
                    },
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              )
            ],
          ));
    });
  }


}

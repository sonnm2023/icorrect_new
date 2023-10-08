// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoMyTest extends StatefulWidget {
  String fileName;
  VideoMyTest({super.key, required this.fileName});

  @override
  State<VideoMyTest> createState() => _VideoMyTestState();
}

class _VideoMyTestState extends State<VideoMyTest> {
  VideoPlayerController? _playerController;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  Future<void> initVideo() async {
    String path =
        '${await FileStorageHelper.getFolderPath(MediaType.video, null)}/${widget.fileName}';

    if (kDebugMode) {
      print('path "$path');
    }

    _playerController = VideoPlayerController.file(File(path))..initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyTestProvider>(
      builder: (context, provider, child) {
        if (_playerController != null) {
          _playerController!.addListener(
            () {
              if (!_playerController!.value.size.isEmpty) {
                if (_playerController!.value.position ==
                    _playerController!.value.duration) {
                  provider.setSampleAudioPlaying(!provider.isSamplePlaying);
                }
              }
            },
          );
        }
        return (_playerController != null)
            ? Container(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        provider
                            .setSampleAudioPlaying(!provider.isSamplePlaying);
                        _playerController!.pause();
                      },
                      child: SizedBox(
                        height: double.infinity,
                        child: AspectRatio(
                          aspectRatio: _playerController!.value.aspectRatio,
                          child: VideoPlayer(_playerController!),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !provider.isSamplePlaying,
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: const Color.fromARGB(153, 86, 86, 86),
                        child: InkWell(
                          onTap: () {
                            provider.setSampleAudioPlaying(
                                !provider.isSamplePlaying);
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
                ),
              )
            : Container();
      },
    );
  }
}

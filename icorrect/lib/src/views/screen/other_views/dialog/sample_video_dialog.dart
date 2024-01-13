// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/my_test_provider.dart';
import 'package:icorrect/src/views/widget/default_text.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class SampleVideo extends StatefulWidget {
  String url;
  SampleVideo({super.key, required this.url});

  @override
  State<SampleVideo> createState() => _SampleVideoState();
}

class _SampleVideoState extends State<SampleVideo> {
  VideoPlayerController? _playerController;

  @override
  void initState() {
    super.initState();
    _playerController = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _playerController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildSampleVideo();
  }

  Widget _buildSampleVideo() {
    return Dialog(
      child: Consumer<MyTestProvider>(
        builder: (context, provider, child) {
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
          return Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: InkWell(
                  onTap: () {
                    _playerController!.pause();
                    _playerController!.dispose();
                    provider.setSampleAudioPlaying(false);
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.cancel_outlined,
                    color: AppColor.defaultGrayColor,
                  ),
                ),
              ),
              Container(
                height: 300,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DefaultText(
                      text: Utils.multiLanguage(StringConstants.sample_video)!,
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 30),
                    Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            provider.setSampleAudioPlaying(
                                !provider.isSamplePlaying);
                            _playerController!.pause();
                          },
                          child: SizedBox(
                            height: 200,
                            child: AspectRatio(
                              aspectRatio: _playerController!.value.aspectRatio,
                              child: VideoPlayer(_playerController!),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !provider.isSamplePlaying,
                          child: Container(
                            height: 200,
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
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

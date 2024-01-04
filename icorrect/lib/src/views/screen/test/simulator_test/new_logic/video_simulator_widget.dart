import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/views/screen/test/simulator_test/new_logic/simulator_test_provider_new.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win.dart';

class VideoSimulatorWidget extends StatefulWidget {
  Function onVideoEnd;

  VideoSimulatorWidget({super.key, required this.onVideoEnd});

  @override
  State<VideoSimulatorWidget> createState() => _VideoSimulatorWidgetState();
}

class _VideoSimulatorWidgetState extends State<VideoSimulatorWidget> {
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isWindows) WindowsVideoPlayer.registerWith();

    return _buildVideoSimulator();
  }

  Widget _buildVideoSimulator() {
    return Consumer<SimulatorTestProviderNew>(
        builder: (context, provider, child) {
      return Column(
        children: [
          Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Shadow color
                          spreadRadius: 5,
                          blurRadius: 5,
                          offset: const Offset(0, 2), // Shadow offset
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child:
                              provider.videoPlayController.value.isInitialized
                                  ? VideoPlayer(provider.videoPlayController)
                                  : const Image(
                                      image: AssetImage(
                                          "AppAssets.img_video_play_holder"))),
                    ),
                  ),
                  Image.asset("AppAssets.img_paste")
                ],
              )),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 400,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: Colors.grey, width: 1)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      minHeight: 7,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColor.defaultPurpleColor),
                      backgroundColor: Colors.white,
                      value: provider.indexQuestion / provider.questionLength,
                    ),
                  ),
                ),
                Text(
                  "${Utils.multiLanguage("question_title")} "
                  "${(provider.indexQuestion).toString()}"
                  "/"
                  "${provider.questionLength.toString()} ",
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          )
        ],
      );
    });
  }
}

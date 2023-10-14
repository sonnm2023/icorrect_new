import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../provider/video_authentication_provider.dart';

class SubmitVideoAuthentication extends StatefulWidget {
  File videoFile;
  Function onClickSubmit;
  Function onClickRecordNewVideo;
  SubmitVideoAuthentication(
      {
        required this.videoFile,
      required this.onClickSubmit,
      required this.onClickRecordNewVideo,
      super.key});

  @override
  State<SubmitVideoAuthentication> createState() =>
      _SubmitVideoAuthenticationState();
}

class _SubmitVideoAuthenticationState extends State<SubmitVideoAuthentication> {
  VideoPlayerController? _playerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _playerController = VideoPlayerController.file(widget.videoFile)
      ..initialize();
    _chewieController = ChewieController(
      allowedScreenSleep: false,
      allowFullScreen: false,
      videoPlayerController: _playerController!,
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_playerController!.value.isPlaying) {
      _playerController!.pause();
    }
    _playerController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Consumer<VideoAuthProvider>(builder: (context, provider, child) {
      print(
          'video width: ${_playerController!.value.size.width}, video height : ${_playerController!.value.size.height}');
      return Container(
        width: w,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: h / 2,
              width: w,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.grey,
                border: Border.all(color: Colors.white, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3), // Shadow color
                    spreadRadius: 5,
                    blurRadius: 5,
                    offset: const Offset(0, 7), // Shadow offset
                  ),
                ],
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.all(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: _playerController!.value.aspectRatio,
                  child: Chewie(controller: _chewieController!),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Confirm to submit your video !",
                    style: TextStyle(
                        color: AppColor.defaultPurpleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text(
                    "This video will be used to confirm when you do your exam. So you want submit this video ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColor.defaultPurpleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400)),
                const SizedBox(height: 20),
                Stack(
                  children: [
                    Visibility(
                        visible: !provider.isSubmitLoading,
                        child: Column(
                          children: [
                            _submitVideoButton(),
                            _deniedSubmitVideoButton()
                          ],
                        )),
                    Visibility(
                        visible: provider.isSubmitLoading,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColor.defaultPurpleColor,
                            ),
                          ),
                        ))
                  ],
                )
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _submitVideoButton() {
    double w = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        widget.onClickSubmit();
      },
      child: Container(
        width: w,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: AppColor.defaultPurpleColor,
            borderRadius: BorderRadius.circular(100)),
        child: const Text("Submit Now",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400)),
      ),
    );
  }

  Widget _deniedSubmitVideoButton() {
    double w = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () async {
        if (widget.videoFile.existsSync()) {
          await widget.videoFile.delete();
        }
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        widget.onClickRecordNewVideo();
      },
      child: Container(
        width: w,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            border: Border.all(color: AppColor.defaultPurpleColor, width: 1.5),
            borderRadius: BorderRadius.circular(100)),
        child: const Text("Record New Video",
            style: TextStyle(
                color: AppColor.defaultPurpleColor,
                fontSize: 18,
                fontWeight: FontWeight.w400)),
      ),
    );
  }
}

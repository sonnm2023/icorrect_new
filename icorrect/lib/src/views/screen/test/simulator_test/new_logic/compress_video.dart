import 'dart:io';

import 'package:flutter/foundation.dart';

class CompressVideo {
  CompressVideo._();
  static final CompressVideo _compressVideo = CompressVideo._();
  factory CompressVideo.instance() => _compressVideo;

  // void compressVideo({
  //   required String inputPath,
  //   required String outputPath,
  //   required Function onSuccess,
  //   required Function onError,
  // }) async {
  //   FFmpeg? ffmpeg;
  //   try {
  //     ffmpeg = createFFmpeg(CreateFFmpegParam());
  //     ffmpeg.setProgress((progress) async {
  //       if (progress.ratio * 100 == 100) {
  //         if (kDebugMode) {
  //           int length = (await File(inputPath).readAsBytes()).lengthInBytes;
  //           print("RECORDING_VIDEO : Video Recording saved to $outputPath, "
  //               "size : ${length / 1024}kb, size ${(length / 1024) / 1024}mb");
  //         }
  //       }
  //     });

  //     // Replace these options with the desired compression settings
  //     String command = '-i'
  //         '$inputPath' // Input video file
  //         '-vf'
  //         'scale=640:480' // Adjust the resolution as needed
  //         '-b:v'
  //         '1024k' // Adjust the video bitrate as needed
  //         '-acodec'
  //         'aac' // Audio codec
  //         '-strict'
  //         ' experimental'
  //         '$outputPath'; // Output video file

  //     if (!ffmpeg.isLoaded()) {
  //       await ffmpeg.load();
  //     }
  //     await ffmpeg.runCommand(command);

  //     // if (rc == 0) {

  //     //   onSuccess();
  //     // } else {
  //     //   if (kDebugMode) {
  //     //     print('Video compression failed with exit code.');
  //     //   }
  //     //   onError();
  //     // }
  //   } finally {
  //     ffmpeg?.exit();
  //   }
  // }

  void compressVideo({
    required String inputPath,
    required String outputPath,
    required Function onSuccess,
    required Function onError,
  }) async {}
}

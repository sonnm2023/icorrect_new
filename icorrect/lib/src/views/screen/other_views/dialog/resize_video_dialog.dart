// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:provider/provider.dart';

class ResizeVideoDialog extends StatefulWidget {
  File videoFile;
  Function(File fileResize) onResizeCompleted;
  Function? onCancelResizeFile;
  Function(String message)? onErrorResizeFile;
  ResizeVideoDialog(
      {required this.videoFile,
      required this.onResizeCompleted,
      this.onCancelResizeFile,
      this.onErrorResizeFile,
      super.key});

  @override
  State<ResizeVideoDialog> createState() => _ResizeVideoDialogState();
}

class _ResizeVideoDialogState extends State<ResizeVideoDialog> {
  LightCompressor? _lightCompressor;

  @override
  void initState() {
    super.initState();
    _lightCompressor = LightCompressor();
    _compressVideo();
  }

  @override
  void dispose() {
    super.dispose();
    _lightCompressor!.cancelCompression();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        children: [
          Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child:
                  Consumer<AuthProvider>(builder: (context, provider, child) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Please wait for preparing submit...',
                          textAlign: TextAlign.center,
                          style: CustomTextStyle.textBoldBlack_16),
                      const SizedBox(height: 10),
                      StreamBuilder<double>(
                        stream: _lightCompressor!.onProgressUpdated,
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.data != null && snapshot.data > 0) {
                            return Column(
                              children: <Widget>[
                                LinearProgressIndicator(
                                  minHeight: 10,
                                  value: snapshot.data / 100,
                                  borderRadius: BorderRadius.circular(100),
                                  backgroundColor:
                                      AppColor.defaultLightGrayColor,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColor.defaultPurpleColor),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${snapshot.data.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      (widget.onCancelResizeFile != null)
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              child: GestureDetector(
                                onTap: () async {
                                  _lightCompressor!.cancelCompression();
                                  Navigator.of(context).pop();
                                  widget.onCancelResizeFile!();
                                },
                                child: const Text(
                                  "Cancel and Later",
                                  style: CustomTextStyle.textBoldPurple_15,
                                ),
                              ),
                            )
                          : Container()
                    ],
                  ),
                );
              }))
        ],
      ),
    );
  }

  Future _compressVideo() async {
    final String videoName = widget.onCancelResizeFile != null
        ? 'VIDEO_AUTH_${DateTime.now().microsecondsSinceEpoch}'
        : 'VIDEO_EXAM_${DateTime.now().microsecondsSinceEpoch}';
    final Stopwatch stopwatch = Stopwatch()..start();
    LogModel? log;
    if (context.mounted) {
      log = await Utils.prepareToCreateLog(context,
          action: LogEvent.compressVideoFile);
    }

    Map<String, dynamic> data = {
      "video_name": videoName,
      "start_time": '${DateTime.now().microsecondsSinceEpoch}',
      "original_size": '${((widget.videoFile.lengthSync()) / 1024) / 1024} Mb'
    };

    final Result response = await _lightCompressor!.compressVideo(
      path: widget.videoFile.path,
      videoQuality: VideoQuality.very_high,
      isMinBitrateCheckEnabled: false,
      video: Video(videoName: videoName),
      android: AndroidConfig(isSharedStorage: true, saveAt: SaveAt.Movies),
      ios: IOSConfig(saveInGallery: false),
    );

    stopwatch.stop();

    //Add duration into log
    data.addEntries(
        [MapEntry("duration", '${stopwatch.elapsed.inSeconds} seconds')]);

    if (response is OnSuccess) {
      if (kDebugMode) {
        print(
            "RECORDING_VIDEO : Video Before Resize: ${((widget.videoFile.lengthSync()) / 1024) / 1024}");
      }
      await widget.videoFile.delete().then((value) {
        widget.onResizeCompleted(File(response.destinationPath));
        int length = File(response.destinationPath).lengthSync();
        if (kDebugMode) {
          print(
              "RECORDING_VIDEO : Video After Resize: ${response.destinationPath},size ${(length / 1024) / 1024}mb");
        }

        //Add log
        data.addEntries(
            [MapEntry("compress_size", "${(length / 1024) / 1024} Mb")]);
        data.addEntries(
            [MapEntry("end_time", '${DateTime.now().microsecondsSinceEpoch}')]);
        Utils.prepareLogData(
          log: log,
          data: data,
          message: "Compress video file",
          status: LogEvent.success,
        );

        Navigator.of(context).pop();
      });
    } else if (response is OnFailure) {
      if (widget.onErrorResizeFile != null) {
        widget.onErrorResizeFile!(StringConstants.error_when_resize_file);

        //Add log
        data.addEntries(
            [MapEntry("end_time", '${DateTime.now().microsecondsSinceEpoch}')]);
        Utils.prepareLogData(
          log: log,
          data: data,
          message: "Compress video file",
          status: LogEvent.failed,
        );

        Navigator.of(context).pop();
      }
    } else if (response is OnCancelled) {}
  }
}

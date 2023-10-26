import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/local/file_storage_helper.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:provider/provider.dart';
// import 'package:video_compress/video_compress.dart';

import '../../../../../core/video_compress_service.dart';

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
    // final Stopwatch stopwatch = Stopwatch()..start();
    final Result response = await _lightCompressor!.compressVideo(
      path: widget.videoFile.path,
      videoQuality: VideoQuality.very_high,
      isMinBitrateCheckEnabled: false,
      video: Video(videoName: videoName),
      android: AndroidConfig(isSharedStorage: true, saveAt: SaveAt.Movies),
      ios: IOSConfig(saveInGallery: false),
    );

    if (response is OnSuccess) {
      if (kDebugMode) {
        print(
            "RECORDING_VIDEO : Video Before Resize: ${((widget.videoFile.lengthSync()) / 1024) / 1024}");
      }
      await widget.videoFile.delete().then((value) {
        widget.onResizeCompleted(File(response.destinationPath));
        if (kDebugMode) {
          int length = File(response.destinationPath).lengthSync();
          print(
              "RECORDING_VIDEO : Video After Resize: ${response.destinationPath},size ${(length / 1024) / 1024}mb");
        }
        Navigator.of(context).pop();
      });
    } else if (response is OnFailure) {
      if (widget.onErrorResizeFile != null) {
        widget.onErrorResizeFile!(StringConstants.error_when_resize_file);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      }
    } else if (response is OnCancelled) {}
  }
}

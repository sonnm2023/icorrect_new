// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/models/log_models/log_model.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:light_compressor/light_compressor.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';

class ResizeVideoDialog extends StatefulWidget {
  File videoFile;
  Function(File fileResize) onResizeCompleted;
  Function()? onSubmitNow;
  Function()? skipAndLater;
  Function()? onErrorResizeFile;
  bool isVideoExam;
  ResizeVideoDialog(
      {required this.videoFile,
      required this.onResizeCompleted,
      required this.isVideoExam,
      this.onSubmitNow,
      this.skipAndLater,
      this.onErrorResizeFile,
      super.key});

  @override
  State<ResizeVideoDialog> createState() => _ResizeVideoDialogState();
}

class _ResizeVideoDialogState extends State<ResizeVideoDialog> {
  AuthProvider? _authProvider;
  Subscription? _subscription;

  double w = 0, h = 0;
  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    Future.delayed(Duration.zero, () {
      _authProvider!.setSkipAction(false);
    });
    if (widget.videoFile.existsSync()) {
      _compressVideo();
    }
  }

  Future _compressVideo() async {
    if (!VideoCompress.isCompressing) {
      final String videoName = widget.onSubmitNow != null
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

      await VideoCompress.setLogLevel(0);

      MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        widget.videoFile.path,
        quality: VideoQuality.LowQuality,
        deleteOrigin: true,
        includeAudio: true,
      );

      _subscription = VideoCompress.compressProgress$.subscribe((event) {
        if (kDebugMode) {
          print('COMPRESS_VIDEO: progress index : $event');
        }
        if (event == 100 && mediaInfo != null) {
          widget.onResizeCompleted(File(mediaInfo.path!));
          Navigator.of(context).pop();
          if (kDebugMode) {
            print("COMPRESS_VIDEO: file: ${mediaInfo.path!}, "
                "exist :${File(mediaInfo.path!).existsSync()}");
          }
        }
      });

      stopwatch.stop();

      if (kDebugMode) {
        print(
            "DEBUG : process compress second: ${stopwatch.elapsed.inSeconds}");
      }

      //Add duration into log
      data.addEntries(
          [MapEntry("duration", '${stopwatch.elapsed.inSeconds} seconds')]);
    } else {
      VideoCompress.cancelCompression();
      widget.onErrorResizeFile!();
    }
  }

  @override
  void dispose() {
    super.dispose();
    disposeAll();
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
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
                      Text(
                        'Please wait for preparing submit...',
                        textAlign: TextAlign.center,
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: AppColor.defaultBlackColor,
                          fontsSize: FontsSize.fontSize_16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(100),
                        backgroundColor: AppColor.defaultLightGrayColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColor.defaultPurpleColor),
                      ),
                      const SizedBox(height: 20),
                      Visibility(
                          visible: !provider.skipAction,
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: GestureDetector(
                              onTap: () async {
                                provider.setSkipAction(widget.isVideoExam);
                                if (widget.isVideoExam) {
                                  provider.setSkipAction(true);
                                } else {
                                  disposeAll();
                                  Navigator.of(context).pop();
                                  widget.skipAndLater!();
                                }
                              },
                              child: Text(
                                StringConstants.skip_and_text,
                                style: CustomTextStyle.textWithCustomInfo(
                                  context: context,
                                  color: AppColor.defaultPurpleColor,
                                  fontsSize: FontsSize.fontSize_15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )),
                      Visibility(
                          visible:
                              provider.skipAction && widget.onSubmitNow != null,
                          child: _warningWhenSkip())
                    ],
                  ),
                );
              }))
        ],
      ),
    );
  }

  Widget _warningWhenSkip() {
    return Container(
      width: w,
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber, color: Colors.amber, size: 30),
          const SizedBox(width: 10),
          SizedBox(
            width: w / 1.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(StringConstants.warning_skip_compress_video_text,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text(
                  StringConstants.warning_skip_compress_video_content,
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                      onTap: () async {
                        _authProvider!.setSkipAction(false);
                      },
                      child: Text(
                        StringConstants.continue_prepare_text,
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: AppColor.defaultBlackColor,
                          fontsSize: FontsSize.fontSize_15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                    Expanded(
                        child: GestureDetector(
                      onTap: () async {
                        Navigator.of(context).pop();
                        if (widget.onSubmitNow != null) {
                          disposeAll();
                          widget.onSubmitNow!();
                        }
                      },
                      child: Text(
                        StringConstants.submit_now_text,
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: AppColor.defaultPurpleColor,
                          fontsSize: FontsSize.fontSize_15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future disposeAll() async {
    VideoCompress.cancelCompression();
    if (_subscription != null) {
      _subscription!.unsubscribe();
    }
  }
}

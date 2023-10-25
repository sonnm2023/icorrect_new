import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';

import '../../../../../core/video_compress_service.dart';

class ResizeVideoDialog extends StatefulWidget {
  File videoFile;
  Function(File fileResize) onResizeCompleted;
  Function? onCancelResizeFile;
  ResizeVideoDialog(
      {required this.videoFile,
      required this.onResizeCompleted,
      this.onCancelResizeFile,
      super.key});

  @override
  State<ResizeVideoDialog> createState() => _ResizeVideoDialogState();
}

class _ResizeVideoDialogState extends State<ResizeVideoDialog> {
  AuthProvider? _authProvider;
  MediaInfo? _mediaInfo;
  Subscription? _subscription;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    Future.delayed(Duration.zero, () async {
      _authProvider!.resetProgressResize();
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription!.unsubscribe();
    }
    VideoCompress.cancelCompression();
  }

  void _compressVideoSubmit() async {
    _mediaInfo = await VideoCompressService.compressVideo(widget.videoFile);
    _subscription = VideoCompress.compressProgress$.subscribe((progress) async {
      _authProvider!.setProgressResize(progress / 100);
      if (kDebugMode) {
        print(
            "DEBUG : progress resize file : ${_authProvider!.progressResize}");
      }
      if (progress == 100) {
        if (kDebugMode) {
          print(
              "DEBUG- Before :${(widget.videoFile.lengthSync() / 1024) / 1024} mb,"
              "After: ${(_mediaInfo!.filesize! / 1024) / 1024} mb ,"
              "path : ${_mediaInfo!.path}");
        }
        await widget.videoFile.delete().then((value) {
          widget.onResizeCompleted(File(_mediaInfo!.path!));
          if (kDebugMode) {
            print(
                "DEBUG : file video record delete : ${widget.videoFile.existsSync()}");
          }
          Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _compressVideoSubmit();
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
                      // LinearProgressIndicator(
                      //   minHeight: 10,
                      //   borderRadius: BorderRadius.circular(100),
                      //   value: provider.progressResize,
                      //   backgroundColor: AppColor.defaultLightGrayColor,
                      //   valueColor: const AlwaysStoppedAnimation<Color>(
                      //       AppColor.defaultPurpleColor),
                      // ),
                      const CircularProgressIndicator(
                        strokeWidth: 4,
                        backgroundColor: AppColor.defaultLightGrayColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColor.defaultPurpleColor,
                        ),
                      ),
                      (widget.onCancelResizeFile != null)
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              child: GestureDetector(
                                onTap: () async {
                                  VideoCompress.cancelCompression();
                                  if (_subscription != null) {
                                    _subscription!.unsubscribe();
                                  }
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
}

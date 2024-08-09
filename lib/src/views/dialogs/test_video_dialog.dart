import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../data_source/constants.dart';
import '../../providers/home_provider.dart';
import '../../utils/utils.dart';

class TestVideoDialog extends StatefulWidget {
  const TestVideoDialog(
      {super.key,
      this.cancelButtonTitle,
      required this.borderRadius,
      required this.hasCloseButton,
      this.okButtonTapped,
      this.cancelButtonTapped, this.closeButtonTapped});

  final String? cancelButtonTitle;
  final double borderRadius;
  final bool hasCloseButton;
  final Function? okButtonTapped;
  final Function? cancelButtonTapped;
  final Function? closeButtonTapped;

  @override
  State<TestVideoDialog> createState() => _TestVideoDialogState();
}

class _TestVideoDialogState extends State<TestVideoDialog> {

  @override
  Widget build(BuildContext context) {
    const double fontSize_15 = 15.0;
    double w = MediaQuery.of(context).size.width;
    return Consumer<HomeProvider>(builder: (context, provider, child) {
      return Center(
        child: SizedBox(
          width: (w < SizeLayout.MyTestScreenSize) ? w : w / 3,
          height: w/3.2,
          child: Dialog(
                elevation: 0,
                backgroundColor: const Color(0xffffffff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'Kiểm tra âm thanh!',
                          style: TextStyle(
                            fontSize: FontsSize.fontSize_18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.defaultPurpleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                            'Hãy nghe xem 1 đoạn video để kiểm tra âm thanh và báo lại giám khảo nếu có vấn đề',
                            textAlign: TextAlign.center,
                            style:
                            TextStyle(fontSize: FontsSize.fontSize_16),
                          ),
                        ),
                        // const SizedBox(height: 5),
                        const Spacer(),
                        SizedBox(
                          width: w/3,
                          child: AspectRatio (
                            aspectRatio: 16 / 9,
                            child: provider.videoPlayerController.value.isInitialized
                                ? VideoPlayer(provider.videoPlayerController)
                                : const Image(
                                    image: AssetImage(
                                      AppAssets.img_video_play_holder,
                                    ),
                                  ))),
                        const Spacer(),
                          const Divider(
                          thickness: 0.5,
                          color: AppColors.defaultPurpleColor,
                        ),
                        const Spacer(),
                        SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  borderRadius: BorderRadius.only(
                                    bottomRight:
                                    Radius.circular(widget.borderRadius),
                                  ),
                                  onTap: () {
                                    // Navigator.of(context).pop();
                                    widget.okButtonTapped!();
                                  },
                                  child: SizedBox(
                                    width: 120,
                                    child: Center(
                                      child: Text(
                                        provider.okTitle,
                                        style: const TextStyle(
                                          fontSize: fontSize_15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.defaultPurpleColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft:
                                    Radius.circular(widget.borderRadius),
                                  ),
                                  highlightColor: Colors.grey[200],
                                  onTap: () {
                                    // if (provider.canDoNextStep) {
                                      if (widget.cancelButtonTapped != null) {
                                        widget.cancelButtonTapped!();
                                      }
                                    // }
                                  },
                                  child: SizedBox(
                                    width: 120,
                                    child: Center(
                                      child: Text(
                                      provider.rightButtonTitle,
                                        style: TextStyle(
                                          fontSize: fontSize_15,
                                          fontWeight: FontWeight.bold,
                                          color: provider.canDoNextStep ? AppColors.defaultPurpleColor : AppColors.defaultGrayColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                    if (widget.hasCloseButton)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Center(
                              child: Icon(Icons.cancel_outlined,
                                  color: Colors.black),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.closeButtonTapped!();
                          },
                        ),
                      )
                    else
                      const SizedBox(),
                  ],
                ),
          ),
        ),
      );
    },);
  }
}

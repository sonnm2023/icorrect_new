import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../data_source/constants.dart';
import '../../providers/home_provider.dart';
import '../../utils/utils.dart';

class TestAudioDialog extends StatefulWidget {
  const TestAudioDialog(
      {super.key,
      this.cancelButtonTitle,
      required this.borderRadius,
      required this.hasCloseButton,
      this.okButtonTapped,
      this.cancelButtonTapped,
      required this.samples, this.closeButtonTapped});

  final String? cancelButtonTitle;
  final double borderRadius;
  final bool hasCloseButton;
  final Function? okButtonTapped;
  final Function? cancelButtonTapped;
  final List<double> samples;
  final Function? closeButtonTapped;

  @override
  State<TestAudioDialog> createState() => _TestAudioDialogState();
}

class _TestAudioDialogState extends State<TestAudioDialog> {
  @override
  Widget build(BuildContext context) {
    const double fontSize_15 = 15.0;
    double w = MediaQuery.of(context).size.width;
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Center(
          child: SizedBox(
            width: (w < SizeLayout.MyTestScreenSize) ? w : w / 3,
            child: Wrap(
              children: [
                Dialog(
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
                            'Kiểm tra MIC!',
                            style: TextStyle(
                              fontSize: FontsSize.fontSize_18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.defaultPurpleColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              provider.descriptionRecordDialog,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: FontsSize.fontSize_16),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Divider(
                            thickness: 0.5,
                            color: AppColors.defaultPurpleColor,
                          ),
                          RectangleWaveform(
                              samples: widget.samples,
                              activeColor: AppColors.purple,
                              inactiveColor: Colors.black26,
                              showActiveWaveform: true,
                              isRoundedRectangle: true,
                              isCentered: true,
                              height: 50,
                              width: 300,
                              maxDuration: provider.maxDuration,
                              elapsedDuration: provider.elapsedDuration),
                          Text(provider.strCountDown,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: FontsSize.fontSize_18,
                                  fontWeight: FontWeight.w600)),
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
                                    child: const SizedBox(
                                      width: 100,
                                      child: Center(
                                        child: Text(
                                          'Nghe lại',
                                          style: TextStyle(
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
                                      widget.cancelButtonTapped!();
                                    },
                                    child: SizedBox(
                                      width: 100,
                                      child: Center(
                                        child: Text(
                                          'Bước tiếp',
                                          style: TextStyle(
                                            fontSize: fontSize_15,
                                            fontWeight: FontWeight.bold,
                                            color: provider.isStartDoingTest? AppColors.defaultPurpleColor : AppColors.defaultGrayColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
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
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

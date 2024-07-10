import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

import '../../../core/app_colors.dart';

class CustomAlertDialog extends StatefulWidget {
  CustomAlertDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.okButtonTitle,
    required this.cancelButtonTitle,
    required this.borderRadius,
    required this.hasCloseButton,
    required this.okButtonTapped,
    required this.cancelButtonTapped,
    this.richText
  }) : super(key: key);

  final String title;
  final String description;
  final String? okButtonTitle;
  final String? cancelButtonTitle;
  final double borderRadius;
  final bool hasCloseButton;
  final Function? okButtonTapped;
  final Function? cancelButtonTapped;
  RichText? richText;

  @override
  // ignore: library_private_types_in_public_api
  _CustomAlertDialogState createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  @override
  Widget build(BuildContext context) {
    const double fontSize_15 = 15.0;
    double w = MediaQuery.of(context).size.width;
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
                      const SizedBox(height: 15),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: FontsSize.fontSize_18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.defaultPurpleColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: widget.richText ?? Text(
                          widget.description,
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(fontSize: FontsSize.fontSize_16),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Divider(
                        thickness: 0.5,
                        color: AppColors.defaultPurpleColor,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: widget.cancelButtonTitle != null
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
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
                                          widget.cancelButtonTitle ??
                                              Utils.instance().multiLanguage(
                                                  StringConstants
                                                      .cancel_button_title),
                                          style: const TextStyle(
                                            fontSize: fontSize_15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.defaultGrayColor,
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
                                      bottomRight:
                                          Radius.circular(widget.borderRadius),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      widget.okButtonTapped!();
                                    },
                                    child: SizedBox(
                                      width: 100,
                                      child: Center(
                                        child: Text(
                                          widget.okButtonTitle ??
                                              StringConstants.ok_button_title,
                                          style: const TextStyle(
                                            fontSize: fontSize_15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.defaultPurpleColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : InkWell(
                                borderRadius: BorderRadius.only(
                                  bottomLeft:
                                      Radius.circular(widget.borderRadius),
                                  bottomRight:
                                      Radius.circular(widget.borderRadius),
                                ),
                                highlightColor: Colors.grey[200],
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: SizedBox(
                                  width: 150,
                                  child: Center(
                                    child: Text(
                                      widget.okButtonTitle ??
                                          Utils.instance().multiLanguage(
                                              StringConstants.ok_button_title),
                                      style: const TextStyle(
                                        fontSize: fontSize_15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.defaultPurpleColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
  }
}

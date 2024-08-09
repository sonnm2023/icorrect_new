import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../data_source/constants.dart';
import '../../utils/utils.dart';

class EnterTextDialog extends StatefulWidget {
  const EnterTextDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.hintText,
    required this.okButtonTitle,
    required this.cancelButtonTitle,
    required this.borderRadius,
    required this.hasCloseButton,
    required this.okButtonTapped,
    required this.cancelButtonTapped, required this.controller, required this.isObscureText,
  }) : super(key: key);

  final String title;
  final String description;
  final String hintText;
  final TextEditingController controller;
  final String? okButtonTitle;
  final String? cancelButtonTitle;
  final double borderRadius;
  final bool hasCloseButton;
  final bool isObscureText;
  final Function? okButtonTapped;
  final Function? cancelButtonTapped;
  @override
  State<EnterTextDialog> createState() => _EnterTextDialogState();
}

class _EnterTextDialogState extends State<EnterTextDialog> {
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
                        child: Text(
                          widget.description,
                          textAlign: TextAlign.center,
                          style:
                          const TextStyle(fontSize: FontsSize.fontSize_16),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: AppColors.purple, width: 1.2),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: TextField(
                            obscureText: widget.isObscureText,
                            controller: widget.controller,
                            decoration: InputDecoration(
                                hintText: widget.hintText,
                                border: InputBorder.none),
                          ),
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
                        child: Row(
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
                                widget.controller.clear();
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
                                // Navigator.of(context).pop();
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
                          widget.controller.clear();
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

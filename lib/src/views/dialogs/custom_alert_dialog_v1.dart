import 'package:flutter/material.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

import '../../../core/app_colors.dart';
import '../../models/homework_models/new_api_135/activities_model.dart';

class CustomAlertDialogV1 extends StatefulWidget {
  const CustomAlertDialogV1({
    Key? key,
    required this.title,
    required this.description,
    required this.okButtonTitle,
    required this.borderRadius,
    required this.okButtonTapped,
  }) : super(key: key);

  final String title;
  final String description;
  final String? okButtonTitle;
  final double borderRadius;
  final Function()? okButtonTapped;


  @override
  // ignore: library_private_types_in_public_api
  _CustomAlertDialogV1State createState() => _CustomAlertDialogV1State();
}

class _CustomAlertDialogV1State extends State<CustomAlertDialogV1> {
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
                      const Divider(
                        thickness: 0.5,
                        color: AppColors.defaultPurpleColor,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: InkWell(
                          borderRadius: BorderRadius.only(
                            bottomLeft:
                            Radius.circular(widget.borderRadius),
                            bottomRight:
                            Radius.circular(widget.borderRadius),
                          ),
                          highlightColor: Colors.grey[200],
                          onTap: () {
                            // Navigator.of(context).pop();
                            widget.okButtonTapped!();
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

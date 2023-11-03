import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';

class ConfirmDialogWidget extends StatelessWidget {
  const ConfirmDialogWidget({
    super.key,
    required this.title,
    required this.message,
    required this.cancelButtonTitle,
    required this.okButtonTitle,
    required this.cancelButtonTapped,
    this.dimissButtonTapped,
    required this.okButtonTapped,
  });

  final String title;
  final String message;
  final String cancelButtonTitle;
  final Function? dimissButtonTapped;
  final String okButtonTitle;
  final Function cancelButtonTapped;
  final Function okButtonTapped;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        children: [
          Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: const EdgeInsets.only(top: 5, right: 5),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        if (dimissButtonTapped != null) {
                          dimissButtonTapped!();
                        }
                      },
                      child: const Icon(Icons.cancel_outlined, size: 25),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15, right: 10, left: 10),
                  margin: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: AppColor.defaultBlackColor,
                          fontsSize: FontsSize.fontSize_16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: CustomTextStyle.textWithCustomInfo(
                          context: context,
                          color: AppColor.defaultBlackColor,
                          fontsSize: FontsSize.fontSize_15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              cancelButtonTapped();
                            },
                            child: Text(
                              cancelButtonTitle,
                              style: CustomTextStyle.textWithCustomInfo(
                                context: context,
                                color: AppColor.defaultGrayColor,
                                fontsSize: FontsSize.fontSize_15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              okButtonTapped();
                            },
                            child: Text(
                              okButtonTitle,
                              style: CustomTextStyle.textWithCustomInfo(
                                context: context,
                                color: AppColor.defaultPurpleColor,
                                fontsSize: FontsSize.fontSize_15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/provider/my_practice_detail_provider.dart';
import 'package:provider/provider.dart';

class NoteViewWidget extends StatelessWidget {
  const NoteViewWidget({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraint) {
        return Container(
          // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  // Container(
                  //   width: double.infinity,
                  //   alignment: Alignment.center,
                  //   margin: const EdgeInsets.only(top: 20, right: 10),
                  //   child: Text(
                  //     Utils.multiLanguage(StringConstants.tips_screen_title)!,
                  //     style: CustomTextStyle.textWithCustomInfo(
                  //       context: context,
                  //       color: Colors.orange,
                  //       fontsSize: FontsSize.fontSize_20,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //   ),
                  // ),
                  Container(
                    alignment: Alignment.topRight,
                    margin: const EdgeInsets.only(top: 10, right: 10),
                    child: InkWell(
                      onTap: () {
                        // Provider.of<AuthProvider>(context, listen: false)
                        //     .setShowDialogWithGlobalScaffoldKey(
                        //         false, GlobalScaffoldKey.showTipScaffoldKey);
                        Provider.of<MyPracticeDetailProvider>(context,
                                listen: false)
                            .updateShowNoteViewStatus(isShow: false);
                      },
                      child: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 5),
              Text(
                message,
                textAlign: TextAlign.center,
                style: CustomTextStyle.textWithCustomInfo(
                  context: context,
                  color: AppColor.defaultBlackColor,
                  fontsSize: FontsSize.fontSize_18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // const SizedBox(height: 5),
              // Container(
              //   margin: const EdgeInsets.symmetric(horizontal: 20),
              //   child: const Divider(
              //     thickness: 1,
              //     color: AppColor.defaultGrayColor,
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}

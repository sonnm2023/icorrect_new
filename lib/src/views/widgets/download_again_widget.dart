import 'package:flutter/material.dart';
import 'package:icorrect_pc/core/app_assets.dart';
import 'package:icorrect_pc/src/data_source/constants.dart';
import 'package:icorrect_pc/src/utils/utils.dart';

import '../../../core/app_colors.dart';
import '../../presenters/my_test_presenter.dart';
import '../../presenters/simulator_test_presenter.dart';

class DownloadAgainWidget extends StatefulWidget {
  DownloadAgainWidget({super.key, required this.onClickTryAgain, required this.isOffline, this.visibleText, this.message, this.backgroundColor});

  final Function onClickTryAgain;
  final bool isOffline;
  bool? visibleText;
  String? message;
  Color? backgroundColor;

  @override
  State<DownloadAgainWidget> createState() => _DownloadAgainWidgetState();
}

class _DownloadAgainWidgetState extends State<DownloadAgainWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: widget.backgroundColor ?? AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Download icon
            Image.asset(
              AppAssets.img_connect_internet,
              width: 120,
              height: 120,
            ),
            //Message
            Padding(
              padding: const EdgeInsets.only(
                  left: 40, top: 10, right: 40, bottom: 10),
              child: Center(
                child: Text(
                setMessage(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ),
            //Try Again button
            InkWell(
              onTap: () {
                widget.onClickTryAgain();
              },
              child: SizedBox(
                width: 100,
                height: 60,
                child: Center(
                  child: Text(
                    Utils.instance()
                        .multiLanguage(StringConstants.try_again_button_title),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.defaultPurpleColor,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String setMessage() {
    if (widget.message != null) {
      return widget.message!;
    } else {
      return Utils.instance().multiLanguage(
          widget.isOffline ? StringConstants.error_during_test_offline : StringConstants.error_during_test_hasInternet);
    }
  }
}

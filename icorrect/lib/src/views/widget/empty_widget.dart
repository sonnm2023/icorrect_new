import 'package:flutter/material.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';

class EmptyWidget {
  EmptyWidget._();
  static final EmptyWidget _widget = EmptyWidget._();
  factory EmptyWidget.init() => _widget;

  Widget buildNothingWidget(
    BuildContext context,
    String message, {
    required double? widthSize,
    required double? heightSize,
  }) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: widthSize,
            height: heightSize,
            child: const Image(
              image: AssetImage(AppAsset.empty),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: CustomTextStyle.textWithCustomInfo(
              context: context,
              color: AppColor.defaultGrayColor,
              fontsSize: FontsSize.fontSize_16,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}

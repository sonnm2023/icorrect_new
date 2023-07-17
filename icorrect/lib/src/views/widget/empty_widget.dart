import 'package:flutter/material.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';

class NothingWidget {
  NothingWidget._();
  static final NothingWidget _widget = NothingWidget._();
  factory NothingWidget.init() => _widget;

  Widget buildNothingWidget(String message,
      {required double? widthSize, required double? heightSize}) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: widthSize,
            height: heightSize,
            child: const Image(
              image: AssetImage(AppAsset.empty),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
                color: AppColor.defaultGrayColor,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}

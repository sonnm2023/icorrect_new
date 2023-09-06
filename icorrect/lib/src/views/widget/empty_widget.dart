import 'package:flutter/material.dart';
import 'package:icorrect/core/app_asset.dart';
import 'package:icorrect/core/app_color.dart';

class EmptyWidget {
  EmptyWidget._();
  static final EmptyWidget _widget = EmptyWidget._();
  factory EmptyWidget.init() => _widget;

  Widget buildNothingWidget(String message,
      {required double? widthSize, required double? heightSize}) {
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
            style: const TextStyle(
              color: AppColor.defaultGrayColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}

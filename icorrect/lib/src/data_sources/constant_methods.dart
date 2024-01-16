import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icorrect/core/app_color.dart';
import 'dart:ui' as ui;
import 'constants.dart';

void printResponse(String text) {
  if (kDebugMode) {
    print('\x1B[33m$text\x1B[0m');
  }
}

void printError(String text) {
  if (kDebugMode) {
    print('\x1B[31m$text\x1B[0m');
  }
}

void printTest(String text) {
  if (kDebugMode) {
    print('\x1B[32m$text\x1B[0m');
  }
}

void showToastMsg(
    {required String msg,
    required ToastStatesType toastState,
    required bool isCenter}) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: isCenter ? ToastGravity.CENTER : ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: const Color.fromARGB(255, 223, 125, 218),
      textColor: AppColor.defaultAppColor,
      fontSize: 15.0);
}

Color chooseToastColor({required ToastStatesType state}) {
  Color color;
  switch (state) {
    case ToastStatesType.success:
      color = AppColor.defaultPurpleColor;
      break;
    case ToastStatesType.warning:
      color = Colors.white;
      break;
    case ToastStatesType.error:
      color = Colors.red;
      break;
  }
  return color;
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

Future<Uint8List> getBytesFromAsset(String path, double width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width.toInt());
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

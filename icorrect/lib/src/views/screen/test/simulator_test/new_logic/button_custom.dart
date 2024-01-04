import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';

class ButtonCustom {
  ButtonCustom._();
  static final ButtonCustom _buttonCustom = ButtonCustom._();
  factory ButtonCustom.init() => _buttonCustom;

  ButtonStyle buttonPurple20() {
    return ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(AppColor.defaultPurpleColor),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
  }

  ButtonStyle buttonBlue20() {
    return ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(const Color(0xFF596D9E)),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
  }

  ButtonStyle buttonWhite20() {
    return ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
  }
}

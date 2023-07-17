import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';

TextSpan defaultTextSpan({
  final String? text,
  final List<InlineSpan>? children,
  final GestureRecognizer? recognizer,
  final MouseCursor? mouseCursor,
  final void Function(PointerEnterEvent)? onEnter,
  final void Function(PointerExitEvent)? onExit,
  final String? semanticsLabel,
  final Locale? locale,
  final bool? spellOut,
  final Color color = AppColor.defaultAppColor,
  final FontWeight? fontWeight = FontWeight.w600,
  final double? fontSize,
  final TextDecoration? textDecoration,
}) {
  return TextSpan(
    text: text,
    children: children,
    style: TextStyle(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize ?? 30,
      decoration: textDecoration,
    ),
    locale: locale,
    mouseCursor: mouseCursor,
    onEnter: onEnter,
    onExit: onExit,
    recognizer: recognizer,
    semanticsLabel: semanticsLabel,
    spellOut: spellOut,
  );
}

import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';

import '../../data_sources/constants.dart';

class AuthFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final String? labelText;
  final TextInputType keyboardType;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onEditingComplete;
  final void Function(String)? onChanged;
  final bool obscureText;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? initialValue;
  final String? hintText;
  final String? upHintText;
  final String? suffixText;
  final TextStyle? suffixTextStyle;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? cursorColor;
  final double radius;
  final double? height;
  final int? maxLines;
  final double horizontalPadding;
  final double verticalPadding;
  final InputBorder? inputBorder;
  final InputBorder? inputEnabledBorder;
  final InputBorder? inputFocusedBorder;
  final InputBorder? inputDisabledBorder;
  final EdgeInsetsGeometry? contentPadding;
  final AlignmentGeometry? containerAlignment;
  final BoxConstraints? suffixIconConstraints;
  final bool readOnly;
  final int? maxLength;
  final int? errorMaxLines;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final TextInputAction? textInputAction;
  final bool autofocus;

  const AuthFormField(
      {Key? key,
      required this.controller,
      this.validator,
      this.onTap,
      this.labelText,
      required this.keyboardType,
      this.onFieldSubmitted,
      this.onEditingComplete,
      this.onChanged,
      this.obscureText = false,
      this.prefixIcon,
      this.suffixIcon,
      this.initialValue,
      this.hintText,
      this.upHintText,
      this.backgroundColor,
      this.height = CustomSize.size_70,
      this.radius = 30.0,
      this.maxLines,
      this.enabled = true,
      this.inputBorder =
          const OutlineInputBorder(borderSide: BorderSide(width: 1)),
      this.inputEnabledBorder,
      this.inputFocusedBorder,
      this.inputDisabledBorder,
      this.horizontalPadding = 0,
      this.verticalPadding = 0,
      this.textColor,
      this.labelColor = AppColor.defaultWhiteColor,
      this.contentPadding,
      this.containerAlignment,
      this.suffixText,
      this.suffixTextStyle,
      this.suffixIconConstraints,
      this.readOnly = false,
      this.cursorColor,
      this.maxLength,
      this.errorMaxLines = 2,
      this.textDirection = TextDirection.ltr,
      this.textAlign = TextAlign.start,
      this.textInputAction = TextInputAction.next,
      this.autofocus = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          alignment: containerAlignment,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextFormField(
            autofocus: autofocus,
            textInputAction: textInputAction,
            maxLength: maxLength,
            readOnly: readOnly,
            cursorColor: cursorColor,
            enabled: enabled,
            textAlignVertical: TextAlignVertical.center,
            textAlign: textAlign,
            maxLines: maxLines,
            textDirection: textDirection,
            initialValue: initialValue,
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            onFieldSubmitted: onFieldSubmitted,
            onEditingComplete: onEditingComplete,
            onChanged: onChanged,
            onTap: onTap,
            obscureText: obscureText,
            style: CustomTextStyle.textBlack_14,
            decoration: InputDecoration(
              counterText: '',
              suffixStyle: suffixTextStyle,
              suffixText: suffixText,
              errorMaxLines: errorMaxLines,
              contentPadding: contentPadding,
              isDense: true,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              suffixIconConstraints: suffixIconConstraints,
              // ignore: deprecated_member_use
              labelStyle: Theme.of(context).textTheme.caption!.copyWith(
                    color: labelColor,
                  ),
              labelText: labelText,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 1.0,
                  color: AppColor.defaultPurpleColor,
                ),
                borderRadius: BorderRadius.circular(13.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 1.0,
                  color: AppColor.defaultPurpleColor,
                ),
                borderRadius: BorderRadius.circular(13.0),
              ),
              hintText: hintText,
              hintStyle: CustomTextStyle.textGrey_14,
              hintTextDirection: TextDirection.ltr,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}

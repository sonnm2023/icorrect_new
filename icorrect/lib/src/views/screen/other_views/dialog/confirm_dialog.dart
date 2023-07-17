import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';

class ConfirmDialogWidget extends StatelessWidget {
  const ConfirmDialogWidget({
    super.key,
    required this.title,
    required this.message,
    required this.cancelButtonTitle,
    required this.okButtonTitle,
    required this.cancelButtonTapped,
    required this.okButtonTapped,
  });

  final String title;
  final String message;
  final String cancelButtonTitle;
  final String okButtonTitle;
  final Function cancelButtonTapped;
  final Function okButtonTapped;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        // The "Yes" button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            okButtonTapped();
          },
          child: Text(okButtonTitle, style: const TextStyle(color: AppColor.defaultPurpleColor),),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            cancelButtonTapped();
          },
          child: Text(cancelButtonTitle, style: const TextStyle(color: Colors.grey),),
        )
      ],
    );
  }
}

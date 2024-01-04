import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';

class MessageDialog extends Dialog {
  BuildContext context;
  String message;

  MessageDialog({required this.context, required this.message, super.key});

  @override
  double? get elevation => 0;

  @override
  ShapeBorder? get shape =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

  @override
  Widget? get child => _buildDialog();

  Widget _buildDialog() {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.width;
    return Container(
      width: w / 3,
      padding: const EdgeInsets.all(20),
      child: Wrap(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(Utils.multiLanguage(StringConstants.dialog_title),
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    textAlign: TextAlign.center,
                    message,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  )),
              const Divider(
                color: AppColor.defaultGrayColor,
                height: 1,
              ),
              const SizedBox(height: 10),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.center),
                  child: Text(
                    Utils.multiLanguage(StringConstants.ok_button_title),
                    style: const TextStyle(
                        color: AppColor.defaultPurpleColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  )),
            ],
          )
        ],
      ),
    );
  }
}

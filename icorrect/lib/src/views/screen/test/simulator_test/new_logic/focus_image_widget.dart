import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';

class FocusImageDialog extends Dialog {
  BuildContext _context;
  String _imagePath;

  FocusImageDialog(this._context, this._imagePath, {super.key});

  @override
  double? get elevation => 0;

  @override
  Color? get backgroundColor => Colors.white;
  @override
  ShapeBorder? get shape =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

  @override
  Widget? get child => _buildDialog();

  Widget _buildDialog() {
    return Wrap(children: [
      Container(
          decoration: BoxDecoration(
              border: Border.all(color: AppColor.defaultPurpleColor),
              borderRadius: BorderRadius.circular(10)),
          width: 500,
          height: 400,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: Image.file(
                      File(_imagePath),
                      fit: BoxFit.cover,
                    )),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.only(top: 5, right: 10),
                  alignment: Alignment.topRight,
                  width: 30,
                  height: 30,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(_context).pop();
                    },
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              )
            ],
          ))
    ]);
  }
}

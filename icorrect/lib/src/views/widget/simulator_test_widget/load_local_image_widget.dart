import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';

class LoadLocalImageWidget extends StatefulWidget {
  final String imageUrl;
  final bool isInRow;

  const LoadLocalImageWidget(
      {super.key, required this.imageUrl, required this.isInRow});

  @override
  State<LoadLocalImageWidget> createState() => _LoadLocalImageWidgetState();
}

class _LoadLocalImageWidgetState extends State<LoadLocalImageWidget> {
  Future<void> _getLocalImagePath() async {
    if (widget.isInRow) {
      localImagePath = await Utils.getLocalImagePath(widget.imageUrl);
    } else {
      localImagePath = widget.imageUrl;
    }
  }

  String? localImagePath;

  @override
  void initState() {
    _getLocalImagePath();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String messageLoadImg = Utils.multiLanguage(
      StringConstants.load_image_error_message,
    );
    if (localImagePath == null) return SizedBox(child: Text(messageLoadImg));

    if (localImagePath!.isEmpty) return SizedBox(child: Text(messageLoadImg));

    if (kDebugMode) {
      print("DEBUG: LoadImageWidget $localImagePath");
    }

    if (widget.isInRow) {
      return SizedBox(
        width: 50,
        height: 50,
        child: Image.file(
          File(localImagePath!),
          fit: BoxFit.fitWidth,
        ),
      );
    } else {
      return Image.file(
        File(localImagePath!),
        fit: BoxFit.fill,
      );
    }
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoadImageWidget extends StatelessWidget {
  final String imageUrl;
  final bool isInRow;

  const LoadImageWidget(
      {super.key, required this.imageUrl, required this.isInRow});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return const SizedBox();

    if (kDebugMode) {
      print("DEBUG: LoadImageWidget $imageUrl");
    }

    if (isInRow) {
      return SizedBox(
        width: 50,
        height: 50,
        child: Image.file(
          File(imageUrl),
          fit: BoxFit.fill,
        ),
      );
      // if (isExist) {
      //   return SizedBox(
      //     width: 50,
      //     height: 50,
      //     child: Image.file(
      //       File(widget.imageUrl),
      //       fit: BoxFit.fill,
      //     ),
      //   );
      // } else {
      //   return const Image(
      //     image: AssetImage("assets/default_photo.png"),
      //     width: 50,
      //     height: 50,
      //   );
      // }
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.fitWidth,
      );
      // if (isExist) {
      //   return Image.file(
      //     File(widget.imageUrl),
      //     fit: BoxFit.fitWidth,
      //   );
      // } else {
      //   return const Text('Không thể tìm thấy hình ảnh');
      // }
    }
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CachedNetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final bool isInRow;

  const CachedNetworkImageWidget(
      {super.key, required this.imageUrl, required this.isInRow});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("DEBUG: CachedNetworkImageWidget: $imageUrl");
    }

    if (imageUrl.isEmpty) return const SizedBox();

    if (isInRow) {
      return CachedNetworkImage(
        width: 50,
        height: 50,
        imageUrl: imageUrl,
        fit: BoxFit.fill,
        placeholder: (context, url) => const Image(
          image: AssetImage("assets/default_photo.png"),
          width: 50,
          height: 50,
        ),
        errorWidget: (context, url, error) => const Icon(
          Icons.error_outline_sharp,
          weight: 80,
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_sharp,
                size: 80,
              ),
              Text('Lỗi tải hình ảnh'),
            ],
          );
        },
      );
    }
  }
}

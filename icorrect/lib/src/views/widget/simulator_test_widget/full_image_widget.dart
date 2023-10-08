import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';

class FullImageWidget extends StatelessWidget {
  final String imageUrl;
  final SimulatorTestProvider provider;

  const FullImageWidget(
      {super.key, required this.imageUrl, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.fitWidth,
                  placeholder: (context, url) => const Image(
                    image: AssetImage("assets/default_photo.png"),
                    width: 50,
                    height: 50,
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: SizedBox(
                width: 50,
                height: 50,
                child: InkWell(
                  onTap: () {
                      provider.resetSelectedQuestionImageUrl();
                      provider.setShowFullImage(false);
                  },
                  child: const Icon(
                    Icons.close,
                    weight: 80,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

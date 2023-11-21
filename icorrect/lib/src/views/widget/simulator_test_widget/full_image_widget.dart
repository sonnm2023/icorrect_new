import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';

class FullImageWidget extends StatefulWidget {
  final String imageUrl;
  final SimulatorTestProvider provider;

  const FullImageWidget(
      {super.key, required this.imageUrl, required this.provider});

  @override
  State<FullImageWidget> createState() => _FullImageWidgetState();
}

class _FullImageWidgetState extends State<FullImageWidget> {
  Future<void> _getLocalImagePath() async {
    localImagePath = await Utils.getLocalImagePath(widget.imageUrl);
  }

  String? localImagePath;

  @override
  void initState() {
    _getLocalImagePath();
    super.initState();
  }

  Widget _buildChildWidget() {
    if (localImagePath == null) {
      return SizedBox(
          child: Text(
              Utils.multiLanguage(StringConstants.load_image_error_message)));
    }

    if (localImagePath!.isEmpty) {
      return SizedBox(
          child: Text(
              Utils.multiLanguage(StringConstants.load_image_error_message)));
    }

    return Image.file(
      File(localImagePath!),
      fit: BoxFit.fill,
    );
  }

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
                child: _buildChildWidget(),
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
                    widget.provider.resetSelectedQuestionImageUrl();
                    widget.provider.setShowFullImage(false);
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

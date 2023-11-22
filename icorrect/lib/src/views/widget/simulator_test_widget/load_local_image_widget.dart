import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:provider/provider.dart';

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
    return Consumer<SimulatorTestProvider>(
      builder: (context, provider, child) {
        if (provider.isVisibleSaveTheTest ||
            provider.submitStatus == SubmitStatus.success) {
          return _buildImageWidget();
        } else {
          if (localImagePath == null) {
            return const SizedBox(
              child: Text(StringConstants.load_image_error_message),
            );
          }

          if (widget.isInRow) {
            return SizedBox(
              width: 50,
              height: 50,
              child: Image.file(
                File(localImagePath!),
                fit: BoxFit.fitHeight,
              ),
            );
          } else {
            return _buildImageWidget();
          }
        }
      },
    );
  }

  Widget _buildImageWidget() {
    if (widget.isInRow) {
      return FutureBuilder<void>(
        future: _getLocalImagePath(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 15,
              height: 15,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(1.5),
                  child: CircularProgressIndicator(strokeWidth: 1.0),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return const Text(StringConstants.load_image_error_message);
          } else {
            return SizedBox(
              width: 50,
              height: 50,
              child: Image.file(
                File(localImagePath!),
                fit: BoxFit.fitHeight,
              ),
            );
          }
        },
      );
    } else {
      return Image.file(
        File(localImagePath!),
        fit: BoxFit.fill,
      );
    }
  }
}

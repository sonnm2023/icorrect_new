import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';
import 'package:icorrect/src/provider/auth_provider.dart';
import 'package:icorrect/src/provider/simulator_test_provider.dart';
import 'package:provider/provider.dart';

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
  AuthProvider? _authProvider;

  @override
  void initState() {
    _getLocalImagePath();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    super.initState();
    Future.delayed(Duration.zero, () {
      _authProvider!
          .setGlobalScaffoldKey(GlobalScaffoldKey.fullImageScaffoldKey);
    });
  }

  Widget _buildChildWidget() {
    String loadImageErrorMessage =
        Utils.multiLanguage(StringConstants.load_image_error_message)!;

    return FutureBuilder<void>(
      future: _getLocalImagePath(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(loadImageErrorMessage);
        } else {
          return Image.file(
            File(localImagePath!),
            fit: BoxFit.fill,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: GlobalScaffoldKey.fullImageScaffoldKey,
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

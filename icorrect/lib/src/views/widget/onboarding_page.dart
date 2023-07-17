import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';
import 'package:icorrect/src/views/widget/default_text.dart';

class OnBoardingPage extends StatelessWidget {
  final String imagePath;
  final String boldText;
  final String smallText;
  const OnBoardingPage({
    Key? key,
    required this.imagePath,
    required this.boldText,
    required this.smallText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Flexible(
            flex: 15,
            child: Image(
              image: AssetImage(imagePath),
            ),
          ),
          const Spacer(),
          DefaultText(
            text: boldText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          DefaultText(
            text: smallText,
            fontSize: 12,
            color: AppColor.defaultGrayColor,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
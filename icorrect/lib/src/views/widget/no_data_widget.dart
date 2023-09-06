import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({super.key, required this.msg});

  final String msg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/ic_emotion_sad.png', width: 150, height: 150),
          Text(
            msg,
            style: const TextStyle(fontSize: 15.0, color: AppColor.defaultBlackColor),
          ),
        ],
      ),
    );
  }
}

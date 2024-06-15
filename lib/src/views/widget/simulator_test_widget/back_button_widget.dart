import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({super.key, required this.backButtonTapped});

  final Function backButtonTapped;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 10,
      child: InkWell(
        onTap: () {
          backButtonTapped();
        },
        child: Container(
          width: 60,
          height: 60,
          alignment: Alignment.centerLeft,
          child: const Icon(
            Icons.arrow_back_outlined,
            color: AppColor.defaultPurpleColor,
            size: 30,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black.withOpacity(0.2),
      child: Center(
        child: Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            color: Colors.white,
          ),
          child: const CircularProgressIndicator(
            strokeWidth: 4,
            backgroundColor: AppColor.defaultLightGrayColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColor.defaultPurpleColor,
            ),
          ),
        ),
      ),
    );
  }
}

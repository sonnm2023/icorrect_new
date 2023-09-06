import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Center(
        child: Image.asset(
          'assets/images/logo6.png',
          width: 180,
          height: 60,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';

class StartNowButtonWidget extends StatelessWidget {
  const StartNowButtonWidget({super.key, required this.startNowButtonTapped});

  final Function startNowButtonTapped;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Text(
            StringConstants.start_now_description,
            style: TextStyle(fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            startNowButtonTapped();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 100,
            height: 60,
            alignment: Alignment.center,
            child: const Center(
              child: Text(
                StringConstants.start_now_button_title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

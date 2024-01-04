import 'package:flutter/material.dart';
import 'package:icorrect/src/data_sources/constants.dart';
import 'package:icorrect/src/data_sources/utils.dart';

class StartNowButtonWidget extends StatelessWidget {
  const StartNowButtonWidget({super.key, required this.startNowButtonTapped});

  final Function startNowButtonTapped;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Utils.multiLanguage("download_file_description"),
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          height: 40,
          alignment: Alignment.center,
          child: Center(
            child: InkWell(
              onTap: () {
                startNowButtonTapped();
              },
              child: Text(
                Utils.multiLanguage(StringConstants.start_now_button_title),
                style: const TextStyle(
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

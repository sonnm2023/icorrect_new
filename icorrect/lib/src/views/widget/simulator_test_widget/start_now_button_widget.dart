import 'package:flutter/material.dart';

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
            "Start the exam now or wait until the processing finished!",
            style: TextStyle(fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: 100,
          height: 40,
          alignment: Alignment.center,
          child: Center(
            child: InkWell(
              onTap: () {
                startNowButtonTapped();
              },
              child: const Text(
                "Start Now",
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

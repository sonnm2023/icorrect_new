import 'package:flutter/material.dart';

class DefaultLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? value;
  const DefaultLoadingIndicator({Key? key, this.color, this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return SizedBox(
      width: w,
      height: h,
      child: Center(
        child: Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            color: Colors.white,
          ),
          child: CircularProgressIndicator(
            color: color,
            value: value,
          ),
        ),
      ),
    );
  }
}

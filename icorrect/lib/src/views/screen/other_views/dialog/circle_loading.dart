import 'package:flutter/material.dart';
import 'package:icorrect/core/app_color.dart';

class CircleLoading {
  OverlayEntry? _loadingEntry;

  void show(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadingEntry = _createdProgressEntry(context);
      Overlay.of(context).insert(_loadingEntry!);
    });
  }

  void hide() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadingEntry?.remove();
      _loadingEntry = null;
    });
  }

  OverlayEntry _createdProgressEntry(BuildContext context) => OverlayEntry(
      builder: (BuildContext context) => Stack(
            children: <Widget>[
              Container(
                color: Colors.black.withOpacity(0.3),
              ),
              Center(
                child: Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      color: Colors.white),
                  child: const CircularProgressIndicator(
                    strokeWidth: 4,
                    backgroundColor: AppColor.defaultLightGrayColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColor.defaultPurpleColor,
                    ),
                  ),
                ),
              )
            ],
          ));

  double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
}
  // Widget _RadioWave(TickerProviderStateMixin ticketMixin) {
  //   AnimationController controller = AnimationController(
  //     vsync: ticketMixin,
  //     duration: const Duration(seconds: 1),
  //   )
  //     ..stop()
  //     ..repeat();
  //   return Container(
  //       width: 50,
  //       height: 50,
  //       padding: const EdgeInsets.all(5),
  //       decoration: const BoxDecoration(
  //           borderRadius: BorderRadius.all(Radius.circular(100)),
  //           color: Colors.white),
  //       child: CustomPaint(
  //           painter: RadioWavePainter(controller),
  //           child: const SizedBox(
  //             width: 200.0,
  //             height: 200.0,
  //           )));
  // }


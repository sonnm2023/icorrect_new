import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FocusUserFaceWidget extends StatefulWidget {
  const FocusUserFaceWidget({super.key});

  @override
  State<FocusUserFaceWidget> createState() => _FocusUserFaceWidgetState();
}

class _FocusUserFaceWidgetState extends State<FocusUserFaceWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
          final zoom = _controller!.value;
        final centerX = 100.0; // Center X coordinate of the square
        final centerY = 100.0; // Center Y coordinate of the square

        final focus = (1.0 - zoom) * 0.5; // Adjust the focus point based on zoom level

        final transformMatrix = Matrix4.identity()
          ..translate(centerX, centerY) // Move to the center
          ..scale(1.0 + zoom) // Apply zoom
          ..translate(-centerX, -centerY) // Move back to original position
          ..translate(centerX * focus, centerY * focus);

        return Center(
          child: Transform(
            transform: transformMatrix,
            child: Container(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: ColoredCornersPainter(),
              ),
            ),
          ),
        );
      },
    );
  }
}
class ColoredCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.transparent;

    final rect = Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height));
    canvas.drawRect(rect, paint);

    final topLeftColor = Colors.amber;
    final topRightColor = Colors.amber;
    final bottomLeftColor = Colors.amber;
    final bottomRightColor = Colors.amber;

    paint.color = topLeftColor;
    canvas.drawRect(Rect.fromPoints(Offset(0, 0), Offset(20, 20)), paint);

    paint.color = topRightColor;
    canvas.drawRect(
        Rect.fromPoints(Offset(size.width - 20, 0), Offset(size.width, 20)),
        paint);

    paint.color = bottomLeftColor;
    canvas.drawRect(
        Rect.fromPoints(Offset(0, size.height - 20), Offset(20, size.height)),
        paint);

    paint.color = bottomRightColor;
    canvas.drawRect(
        Rect.fromPoints(Offset(size.width - 20, size.height - 20),
            Offset(size.width, size.height)),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}




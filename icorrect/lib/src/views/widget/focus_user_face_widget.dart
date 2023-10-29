import 'package:flutter/material.dart';

class FocusUserFaceWidget extends StatefulWidget {
  const FocusUserFaceWidget({super.key});

  @override
  State<FocusUserFaceWidget> createState() => _FocusUserFaceWidgetState();
}

class _FocusUserFaceWidgetState extends State<FocusUserFaceWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 2, end: 1.3).animate(_controller!);
    _controller!.forward();
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
        return Center(
          child: Transform.scale(
            scale: _animation!.value,
            child: SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: CornerBorderPainter(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CornerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 228, 171, 0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const cornerSize = 30.0;
    const halfCornerSize = cornerSize / 2;

    // Draw perpendicular lines in each corner
    // Top-left corner
    canvas.drawLine(const Offset(0, halfCornerSize),
        const Offset(halfCornerSize, halfCornerSize), paint);
    canvas.drawLine(const Offset(halfCornerSize, 0),
        const Offset(halfCornerSize, halfCornerSize), paint);

    // Top-right corner
    canvas.drawLine(Offset(size.width, halfCornerSize),
        Offset(size.width - halfCornerSize, halfCornerSize), paint);
    canvas.drawLine(Offset(size.width - halfCornerSize, 0),
        Offset(size.width - halfCornerSize, halfCornerSize), paint);

    // Bottom-left corner
    canvas.drawLine(Offset(0, size.height - halfCornerSize),
        Offset(halfCornerSize, size.height - halfCornerSize), paint);
    canvas.drawLine(Offset(halfCornerSize, size.height),
        Offset(halfCornerSize, size.height - halfCornerSize), paint);

    // Bottom-right corner
    canvas.drawLine(
        Offset(size.width, size.height - halfCornerSize),
        Offset(size.width - halfCornerSize, size.height - halfCornerSize),
        paint);
    canvas.drawLine(
        Offset(size.width - halfCornerSize, size.height),
        Offset(size.width - halfCornerSize, size.height - halfCornerSize),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

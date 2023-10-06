import 'package:flutter/material.dart';

class TicketContainerMinimalPainter extends CustomPainter {
  TicketContainerMinimalPainter(
      {required this.left,
      required this.radius,
      required this.backColor,
      required this.shadowColor});

  final double left;
  final double radius;
  final Color backColor;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    Path ticketPath = Path()
      ..moveTo(0, 0)
      ..lineTo(left, 0)
      ..lineTo(size.width - 15, 0)
      ..cubicTo(size.width - 10, 0, size.width - 1, 1, size.width, 10)
      ..lineTo(size.width, left)
      ..arcToPoint(Offset(size.width, left + radius),
          radius: Radius.circular(1), clockwise: false)
      ..lineTo(size.width, size.height - 10)
      ..cubicTo(size.width, size.height - 10, size.width - 1, size.height - 1,
          size.width - 10, size.height)
      ..lineTo(left + radius, size.height)
      ..lineTo(10, size.height)
      ..cubicTo(10, size.height, 1, size.height - 1, 0, size.height - 10)
      ..lineTo(0, left + radius)
      ..arcToPoint(Offset(0, left),
          radius: Radius.circular(1), clockwise: false)
      ..lineTo(0, 10)
      ..cubicTo(0, 10, 1, 1, 10, 0)
      ..close();

    Path shadowPath = Path()
      ..moveTo(-2, -2)
      ..lineTo(left, -2)
      ..lineTo(size.width - 15, -2)
      ..cubicTo(size.width - 10, -2, size.width + 1, -1, size.width + 2, 10)
      ..lineTo(size.width + 2, left)
      ..arcToPoint(Offset(size.width + 2, left + radius),
          radius: Radius.circular(1), clockwise: false)
      ..lineTo(size.width + 2, size.height - 10)
      ..cubicTo(size.width + 2, size.height - 10, size.width + 1,
          size.height + 1, size.width - 10, size.height + 2)
      ..lineTo(left + radius, size.height + 2)
      ..lineTo(10, size.height + 2)
      ..cubicTo(10, size.height + 2, -1, size.height + 1, -2, size.height - 10)
      ..lineTo(-2, left + radius)
      ..arcToPoint(Offset(-2, left),
          radius: Radius.circular(1), clockwise: false)
      ..lineTo(-2, 10)
      ..cubicTo(-2, 10, -1, -1, 10, -2)
      ..close();

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = backColor;

    canvas.drawShadow(shadowPath, shadowColor, 3, true);
    canvas.drawPath(ticketPath, paint);
  }

  @override
  bool shouldRepaint(TicketContainerMinimalPainter oldDelegate) => false;
}

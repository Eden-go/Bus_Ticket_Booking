import 'package:flutter/material.dart';

class TicketContainerDefaultPainter extends CustomPainter {
  TicketContainerDefaultPainter(
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
      ..arcToPoint(Offset((left + radius).toDouble(), 0),
          radius: Radius.circular(1), clockwise: false)
      ..lineTo(size.width - 15, 0)
      ..cubicTo(size.width - 10, 0, size.width - 1, 1, size.width, 10)
      ..lineTo(size.width, size.height - 10)
      ..cubicTo(size.width, size.height - 10, size.width - 1, size.height - 1,
          size.width - 10, size.height)
      ..lineTo(left + radius, size.height)
      ..arcToPoint(Offset((left).toDouble(), size.height),
          radius: Radius.circular(10), clockwise: false)
      ..lineTo(10, size.height)
      ..cubicTo(10, size.height, 1, size.height - 1, 0, size.height - 10)
      ..lineTo(0, 10)
      ..cubicTo(0, 10, 1, 1, 10, 0)
      ..close();

    Path shadowPath = Path()
      ..moveTo(-2, -2)
      ..lineTo(left, -2)
      ..arcToPoint(Offset((left + radius).toDouble(), -2),
          radius: Radius.circular(1), clockwise: false)
      ..lineTo(size.width - 15, -2)
      ..cubicTo(size.width - 10, -2, size.width + 1, -1, size.width + 2, 10)
      ..lineTo(size.width + 2, size.height - 10)
      ..cubicTo(size.width + 2, size.height - 10, size.width + 1,
          size.height + 1, size.width - 10, size.height + 2)
      ..lineTo(left + radius, size.height + 2)
      ..arcToPoint(Offset((left + 0.5).toDouble(), size.height + 1),
          radius: Radius.circular(10), clockwise: false)
      ..lineTo(10, size.height + 2)
      ..cubicTo(10, size.height + 2, -1, size.height + 1, -2, size.height - 10)
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
  bool shouldRepaint(TicketContainerDefaultPainter oldDelegate) => false;
}

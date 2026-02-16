import 'package:flutter/material.dart';

abstract class Drawable {
  void draw(Canvas canvas);
}

class Line extends Drawable {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;

  Line({
    required this.start,
    required this.end,
    this.color = Colors.black,
    this.strokeWidth = 2.0,
  });

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    canvas.drawLine(start, end, paint);
  }
}

class Rectangle extends Drawable {
  final Offset topLeft;
  final Offset bottomRight;
  final Color color;
  final double strokeWidth;
  final PaintingStyle style;

  Rectangle({
    required this.topLeft,
    required this.bottomRight,
    this.color = Colors.black,
    this.strokeWidth = 2.0,
    this.style = PaintingStyle.stroke,
  });

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = style
      ..strokeWidth = strokeWidth;
    canvas.drawRect(
      Rect.fromPoints(topLeft, bottomRight),
      paint,
    );
  }
}

class Circle extends Drawable {
  final Offset center;
  final double radius;
  final Color color;
  final double strokeWidth;
  final PaintingStyle style;

  Circle({
    required this.center,
    required this.radius,
    this.color = Colors.black,
    this.strokeWidth = 2.0,
    this.style = PaintingStyle.stroke,
  });

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = style
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, paint);
  }
}

class TextElement extends Drawable {
  final String text;
  final Offset position;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final String? fontFamily;

  TextElement({
    required this.text,
    required this.position,
    this.color = Colors.black,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    this.fontFamily,
  });

  @override
  void draw(Canvas canvas) {
    final textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontFamily: fontFamily
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }
}

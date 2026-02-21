import 'package:flutter/material.dart';
import 'dart:math';

abstract class Drawable {
  final String id; // Identificador únic per a cada Drawable
  Color color;

  Drawable({required this.id, required this.color});

  void draw(Canvas canvas);

  // Per seleccionar
  Offset get centerPoint;

  // Per moure
  void updatePosition(Offset offset, bool absolute);

  // Crear còpia amb propietats modificades
  Drawable copyWith({
    Color? color,
  });

  // Per ressaltar seleccionats
  Rect get bounds;
}

class Line extends Drawable {
  Offset start;
  Offset end;
  double strokeWidth;

  Line({
    String? id,
    required this.start,
    required this.end,
    Color color = Colors.black,
    this.strokeWidth = 2.0,
  }) : super(
    id : id ?? 'line_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}',
    color: color,
  );

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    canvas.drawLine(start, end, paint);
  }

  @override
  Offset get centerPoint => Offset(
    (start.dx + end.dx) / 2,
    (start.dy + end.dy) / 2,
  );

  @override
  void updatePosition(Offset offset, bool absolute) {
    if (absolute) {
      end = Offset(offset.dx + end.dx - start.dx, offset.dy + end.dy - start.dy);
      start = Offset(offset.dx, offset.dy);
    } else {
      start = Offset(start.dx + offset.dx, start.dy + offset.dy);
      end = Offset(end.dx + offset.dx, end.dy + offset.dy);
    }
  }

  @override
  Drawable copyWith({
    Color? color,
    double? strokeWidth,
    Offset? start,
    Offset? end,
  }) {
    return Line(
      id: id,
      start: start ?? this.start,
      end: end ?? this.end,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  Rect get bounds => Rect.fromPoints(
    Offset(min(start.dx, end.dx), min(start.dy, end.dy)),
    Offset(max(start.dx, end.dx), max(start.dy, end.dy)),
  );
}

class Rectangle extends Drawable {
  Offset topLeft;
  Offset bottomRight;
  double strokeWidth;
  PaintingStyle style;

  Rectangle({
    String? id,
    required this.topLeft,
    required this.bottomRight,
    Color color = Colors.black,
    this.strokeWidth = 2.0,
    this.style = PaintingStyle.stroke,
  }) : super(
    id: id ?? 'rect_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}',
    color: color
  );

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

  @override
  Offset get centerPoint => Offset(
    (topLeft.dx + bottomRight.dx) / 2,
    (topLeft.dy + bottomRight.dy) / 2,
  );

  @override
  void updatePosition(Offset offset, bool absolute) {
    if (absolute) {
      bottomRight = Offset(offset.dx + bottomRight.dx - topLeft.dx, offset.dy + bottomRight.dy - topLeft.dy);
      topLeft = Offset(offset.dx, offset.dy);
    } else {
      topLeft = Offset(topLeft.dx + offset.dx, topLeft.dy + offset.dy);
      bottomRight = Offset(bottomRight.dx + offset.dx, bottomRight.dy + offset.dy);
    }
  }

  @override
  Drawable copyWith({
    Color? color,
    double? strokeWidth,
    Offset? topLeft,
    Offset? bottomRight,
    PaintingStyle? style,
  }) {
    return Rectangle(
      id: id,
      topLeft: topLeft ?? this.topLeft,
      bottomRight: bottomRight ?? this.bottomRight,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      style: style ?? this.style,
    );
  }

  @override
  Rect get bounds => Rect.fromPoints(topLeft, bottomRight);
}

class Circle extends Drawable {
  Offset center;
  double radius;
  double strokeWidth;
  PaintingStyle style;

  Circle({
    String? id,
    required this.center,
    required this.radius,
    Color color = Colors.black,
    this.strokeWidth = 2.0,
    this.style = PaintingStyle.stroke,
  }) : super(
    id: id ?? 'circle_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}',
    color: color,
  );

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = style
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  Offset get centerPoint => center;

  @override
  void updatePosition(Offset offset, bool absolute) {
    if (absolute) {
      center = Offset(offset.dx, offset.dy);
    } else {
      center = Offset(center.dx + offset.dx, center.dy + offset.dy);
    }
  }

  @override
  Drawable copyWith({
    Color? color,
    double? strokeWidth,
    Offset? center,
    double? radius,
    PaintingStyle? style,
  }) {
    return Circle(
      id: id,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      style: style ?? this.style,
    );
  }

  @override
  Rect get bounds => Rect.fromCircle(center: center, radius: radius);
}

class TextElement extends Drawable {
  String text;
  Offset position;
  double fontSize;
  FontWeight fontWeight;
  FontStyle fontStyle;
  String? fontFamily;

  TextElement({
    String? id,
    required this.text,
    required this.position,
    Color color = Colors.black,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    this.fontFamily,
  }) : super(
    id: id ?? 'text_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}',
    color: color,
  );

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

  @override
  Offset get centerPoint => position;

  @override
  void updatePosition(Offset offset, bool absolute) {
    if (absolute) {
      position = Offset(offset.dx, offset.dy);
    } else {
      position = Offset(position.dx + offset.dx, position.dy + offset.dy);
    }
  }

  @override
  Drawable copyWith({
    Color? color,
    double? strokeWidth,
    String? text,
    Offset? position,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    String? fontFamily,
  }) {
    return TextElement(
      id: id,
      text: text ?? this.text,
      position: position ?? this.position,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  @override
  Rect get bounds => Rect.fromLTWH(
    position.dx,
    position.dy,
    text.length * fontSize * 0.6, // Aproximat
    fontSize * 1.2,
  );
}

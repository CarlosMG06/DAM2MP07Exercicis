import 'drawable.dart';
import 'package:flutter/material.dart';

class CanvasPainter extends CustomPainter {
  final List<Drawable> drawables;
  final List<String> selectedIds;

  CanvasPainter({
    required this.drawables,
    required this.selectedIds,
  });

  @override
  void paint(Canvas canvas, Size size) {

    for (var drawable in drawables) {
      drawable.draw(canvas);
    }

    // Ressaltar seleccionats
    if (selectedIds.isNotEmpty) {
      final paint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      for (var drawable in drawables) {
        if (selectedIds.contains(drawable.id)) {
          canvas.drawRect(drawable.bounds, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

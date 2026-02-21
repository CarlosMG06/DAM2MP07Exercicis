import 'package:flutter/material.dart';
import 'drawable.dart';

class SelectionManager extends ChangeNotifier {
  final List<String> _selectedIds = [];
  
  List<Drawable> getSelectedDrawables(List<Drawable> allDrawables) {
    return allDrawables.where((d) => _selectedIds.contains(d.id)).toList();
  }
  List<String> getSelectedIds() => List.from(_selectedIds);
  
  bool isSelected(String id) => _selectedIds.contains(id);
  
  void select(String id, {bool multiSelect = false}) {
    if (!multiSelect) {
      _selectedIds.clear();
    }
    if (!_selectedIds.contains(id)) {
      _selectedIds.add(id);
    }
    notifyListeners();
  }
  
  // void selectAll(List<Drawable> drawables) {
  //   _selectedIds.clear();
  //   _selectedIds.addAll(drawables.map((d) => d.id));
  //   notifyListeners();
  // }
  
  // void deselect(String id) {
  //   _selectedIds.remove(id);
  //   notifyListeners();
  // }
  
  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }
  
  // Drawable? findDrawableAtPoint(List<Drawable> drawables, Offset point) {
  //   // Search in reverse order (top-most first)
  //   for (int i = drawables.length - 1; i >= 0; i--) {
  //     if (drawables[i].containsPoint(point)) {
  //       return drawables[i];
  //     }
  //   }
  //   return null;
  // }
  
  // List<String> findDrawablesInRect(List<Drawable> drawables, Rect rect) {
  //   return drawables
  //       .where((d) => rect.overlaps(d.bounds))
  //       .map((d) => d.id)
  //       .toList();
  // }
  
  // List<Drawable> findByType<T extends Drawable>(List<Drawable> drawables) {
  //   return drawables.whereType<T>().toList();
  // }
  
  // List<Drawable> findByColor(List<Drawable> drawables, Color color) {
  //   return drawables.where((d) => d.color.value == color.value).toList();
  // }
}
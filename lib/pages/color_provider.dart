import 'package:flutter/material.dart';

class ColorProvider extends ChangeNotifier {
  Color _selectedColor = Colors.blue; // اللون الافتراضي

  Color get selectedColor => _selectedColor;

  void updateColor(Color newColor) {
    _selectedColor = newColor;
    notifyListeners(); // إشعار التغييرات لجميع الصفحات
  }
}

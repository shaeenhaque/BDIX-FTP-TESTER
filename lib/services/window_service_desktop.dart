import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'window_service_interface.dart';

class WindowServiceDesktop implements WindowServiceInterface {
  @override
  Future<void> initialize() async {
    await windowManager.ensureInitialized();
  }

  @override
  Future<void> setMinimumSize(double width, double height) async {
    await windowManager.setMinimumSize(Size(width, height));
  }

  @override
  Future<void> setTitle(String title) async {
    await windowManager.setTitle(title);
  }
}

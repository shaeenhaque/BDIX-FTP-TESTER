import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> initializeWindow() async {
  await windowManager.ensureInitialized();
  await windowManager.setTitle('BDIX FTP Tester');
  await windowManager.setMinimumSize(const Size(800, 600));
}

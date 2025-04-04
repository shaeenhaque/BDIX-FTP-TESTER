import 'dart:io' show Platform;
import 'window_service_interface.dart';
import 'window_service_desktop.dart';
import 'window_service_mobile.dart';

class WindowService {
  static final WindowServiceInterface _instance =
      Platform.isWindows || Platform.isMacOS || Platform.isLinux
          ? WindowServiceDesktop()
          : WindowServiceMobile();

  static WindowServiceInterface get instance => _instance;
}

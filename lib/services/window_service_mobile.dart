import 'window_service_interface.dart';

class WindowServiceMobile implements WindowServiceInterface {
  @override
  Future<void> initialize() async {
    // No initialization needed for mobile
  }

  @override
  Future<void> setMinimumSize(double width, double height) async {
    // No-op on mobile
  }

  @override
  Future<void> setTitle(String title) async {
    // No-op on mobile
  }
}

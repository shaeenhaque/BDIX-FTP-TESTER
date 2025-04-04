abstract class WindowServiceInterface {
  Future<void> initialize();
  Future<void> setMinimumSize(double width, double height);
  Future<void> setTitle(String title);
}

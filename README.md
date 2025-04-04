# BDIX FTP TESTER

A cross-platform application to test and manage BDIX FTP servers.

## Features

- Test FTP server connections
- Monitor server response times
- Cross-platform support (Windows, Linux, macOS, Android)
- Modern and intuitive user interface

## Downloads

You can download the latest version for your platform from the [Releases](../../releases) page.

## Building from Source

### Prerequisites

- Flutter SDK (latest stable version)
- For desktop builds:
  - Windows: Visual Studio with C++ development tools
  - Linux: GTK development libraries
  - macOS: Xcode
- For Android builds: Android SDK and NDK

### Build Instructions

1. Clone the repository:
```bash
git clone https://github.com/FakeErrorX/BDIX-FTP-TESTER.git
cd BDIX-FTP-TESTER
```

2. Get dependencies:
```bash
flutter pub get
```

3. Build for your platform:
```bash
# For Windows
flutter build windows

# For Linux
flutter build linux

# For macOS
flutter build macos

# For Android
flutter build apk
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

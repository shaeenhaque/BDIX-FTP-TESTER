# BDIX FTP Tester

A modern cross-platform application to test BDIX FTP links and show working servers. Built with Flutter, this application supports Windows, Linux, macOS, and Android.

## Features

- Test multiple FTP links simultaneously
- Modern and clean user interface
- Dark and light theme support
- Real-time response time monitoring
- Cross-platform support (Windows, Linux, macOS, Android)
- Automatic builds via GitHub Actions

## Installation

### Windows
1. Download the latest Windows release from the [Releases](../../releases) page
2. Extract the ZIP file
3. Run `bdix_ftp_tester.exe`

### Linux
1. Download the latest Linux release from the [Releases](../../releases) page
2. Extract the archive
3. Make the file executable: `chmod +x bdix_ftp_tester`
4. Run the application: `./bdix_ftp_tester`

### macOS
1. Download the latest macOS release from the [Releases](../../releases) page
2. Mount the DMG file
3. Drag the application to your Applications folder
4. Run the application

### Android
1. Download the latest APK from the [Releases](../../releases) page
2. Install the APK on your Android device
3. Run the application

## Development

### Prerequisites
- Flutter SDK (latest stable version)
- For desktop development:
  - Windows: Visual Studio with C++ development tools
  - Linux: GTK development headers
  - macOS: Xcode
- For Android development:
  - Android Studio
  - Android SDK

### Setup
1. Clone the repository:
```bash
git clone https://github.com/yourusername/bdix-ftp-tester.git
cd bdix-ftp-tester
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
# For desktop
flutter run -d windows
flutter run -d linux
flutter run -d macos

# For Android
flutter run -d android
```

## Building

The application is automatically built using GitHub Actions when:
- A push is made to the main branch
- A pull request is created targeting the main branch
- A new release is created

To manually build the application:

```bash
# Windows
flutter build windows

# Linux
flutter build linux

# macOS
flutter build macos

# Android
flutter build apk
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

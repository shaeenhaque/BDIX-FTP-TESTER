import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/ftp_link.dart';

class FtpService {
  static const int _timeout = 5000; // 5 seconds timeout
  static const int _concurrentTests = 20;
  static const int _pingAttempts = 3; // Number of ping attempts for averaging

  Future<(bool, int)> pingHost(String url) async {
    try {
      final uri = Uri.parse(url);
      final times = <int>[];

      // Take multiple measurements
      for (var i = 0; i < _pingAttempts; i++) {
        final stopwatch = Stopwatch()..start();
        try {
          final socket = await Socket.connect(
            uri.host,
            uri.port > 0 ? uri.port : 21,
            timeout: const Duration(milliseconds: _timeout),
          );
          await socket.close();
          stopwatch.stop();
          times.add(stopwatch.elapsedMilliseconds);
        } catch (e) {
          stopwatch.stop();
          // If we have at least one successful measurement, continue
          if (times.isNotEmpty) continue;
          return (false, _timeout);
        }
      }

      if (times.isEmpty) return (false, _timeout);

      // Remove outliers (values more than 2 standard deviations from mean)
      if (times.length > 2) {
        final mean = times.reduce((a, b) => a + b) / times.length;
        final squaredDiffs = times.map((t) => (t - mean) * (t - mean));
        final variance = squaredDiffs.reduce((a, b) => a + b) / times.length;
        final stdDev = sqrt(variance);
        times.removeWhere((t) => (t - mean).abs() > 2 * stdDev);
      }

      // Calculate average of remaining times
      final avgTime = times.isEmpty
          ? _timeout
          : (times.reduce((a, b) => a + b) / times.length).round();

      // Ensure we don't return 0 ms (minimum 1ms)
      return (true, avgTime < 1 ? 1 : avgTime);
    } catch (e) {
      return (false, _timeout);
    }
  }

  Future<bool> testHttpGet(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'BDIX-FTP-Tester/1.0'},
      ).timeout(const Duration(milliseconds: _timeout));

      // For FTP servers, any response in 200-399 range or 401 (auth required) indicates the server is up
      return response.statusCode >= 200 && response.statusCode < 400 ||
          response.statusCode == 401;
    } catch (e) {
      return false;
    }
  }

  Future<FtpLink> testLink(String url) async {
    final link = FtpLink(url: url);

    try {
      // First try ping
      final (isPingSuccessful, pingTime) = await pingHost(url);

      if (!isPingSuccessful) {
        link.isWorking = false;
        link.responseTime = _timeout;
        return link;
      }

      // Store the ping time
      link.responseTime = pingTime;

      // If ping succeeds, try HTTP GET request
      final isHttpWorking = await testHttpGet(url);
      link.isWorking = isHttpWorking;

      // Keep the ping time even if HTTP fails
      if (!isHttpWorking) {
        // Try one more time with a different path
        final altUrl = url.endsWith('/') ? '${url}index.html' : '$url/';
        link.isWorking = await testHttpGet(altUrl);
      }
    } catch (e) {
      link.isWorking = false;
      link.responseTime = _timeout;
    }

    return link;
  }

  Stream<List<FtpLink>> testMultipleLinksStream(List<String> urls) async* {
    final workingLinks = <FtpLink>[];
    final chunks = <List<String>>[];

    // Split URLs into chunks of _concurrentTests
    for (var i = 0; i < urls.length; i += _concurrentTests) {
      chunks.add(
        urls.sublist(
            i,
            i + _concurrentTests > urls.length
                ? urls.length
                : i + _concurrentTests),
      );
    }

    for (final chunk in chunks) {
      final futures = chunk.map((url) => testLink(url));
      final results = await Future.wait(futures);

      // Add working links to the list
      workingLinks.addAll(results.where((link) => link.isWorking));

      // Yield the current list of working links
      yield List<FtpLink>.from(workingLinks);
    }
  }
}

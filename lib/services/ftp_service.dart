import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ftp_link.dart';

class FtpService {
  static const int _timeout = 5000; // 5 seconds timeout
  static const int _concurrentTests = 20;

  Future<(bool, int)> pingHost(String url) async {
    try {
      final uri = Uri.parse(url);
      final result =
          await Process.run('ping', ['-n', '1', '-w', '3000', uri.host]);

      if (result.exitCode == 0) {
        // Parse the ping time from output
        final output = result.stdout.toString();
        final timeMatch = RegExp(r'time=(\d+)ms').firstMatch(output);
        final pingTime = timeMatch != null ? int.parse(timeMatch.group(1)!) : 0;
        return (true, pingTime);
      }

      return (false, _timeout);
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

import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/ftp_link.dart';

class FtpService {
  static const int _timeout = 5000; // 5 seconds timeout
  static const int _concurrentTests = 20;

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
    final stopwatch = Stopwatch()..start();

    try {
      // Try HTTP GET request
      link.isWorking = await testHttpGet(url);

      if (!link.isWorking) {
        // Try one more time with a different path
        final altUrl = url.endsWith('/') ? '${url}index.html' : '$url/';
        link.isWorking = await testHttpGet(altUrl);
      }

      stopwatch.stop();
      link.responseTime = stopwatch.elapsedMilliseconds;
    } catch (e) {
      stopwatch.stop();
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/ftp_provider.dart';
import '../providers/theme_provider.dart';
import '../models/ftp_link.dart';
import '../utils/ftp_links.dart';
import '../utils/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isTesting = false;
  bool _showLanding = true;
  int _totalTested = 0;
  int _totalLinks = 0;

  @override
  void initState() {
    super.initState();
    // Delay initialization to ensure widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(ftpLinksProvider.notifier).initializeLinks(FtpLinks.links);
      }
    });
  }

  Future<void> _startTesting() async {
    setState(() {
      _showLanding = false;
      _isTesting = true;
      _totalTested = 0;
      _totalLinks = FtpLinks.links.length;
    });

    final stream = ref.read(ftpLinksProvider.notifier).testLinksStream();
    await for (final _ in stream) {
      if (mounted) {
        setState(() => _totalTested += 20); // We test 20 links at a time
        if (_totalTested > _totalLinks) _totalTested = _totalLinks;
      }
    }

    if (mounted) {
      setState(() => _isTesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final links = ref.watch(ftpLinksProvider);
    final theme = Theme.of(context);

    if (_showLanding) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.secondary],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'BDIX FTP Link Checker',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .fadeIn(duration: const Duration(seconds: 1))
                    .then()
                    .shimmer(duration: const Duration(seconds: 2)),
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.network_check, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Live server status updates',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 400))
                    .scale(),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _startTesting,
                  icon: const Icon(Icons.play_circle),
                  label: const Text('Start Testing'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 800))
                    .scale()
                    .then()
                    .shimmer(delay: const Duration(seconds: 1)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live BDIX FTP Status'),
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(themeProvider) == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: AppTheme.success),
                            const SizedBox(width: 8),
                            Text(
                              'Working Servers',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        if (_isTesting)
                          Text(
                            'Testing: ${_totalTested}/${_totalLinks}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppTheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${links.length}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppTheme.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isTesting)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _totalTested / _totalLinks,
                      minHeight: 10,
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ).animate().fadeIn().scale(),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: links.length,
              itemBuilder: (context, index) {
                final link = links[index];
                return _LinkCard(link: link, context: context)
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 300),
                    )
                    .slideX(
                      begin: 0.2,
                      duration: const Duration(milliseconds: 300),
                    );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: !_isTesting
          ? FloatingActionButton.extended(
              onPressed: _startTesting,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ).animate().fadeIn().scale()
          : null,
    );
  }
}

class _LinkCard extends StatelessWidget {
  final FtpLink link;
  final BuildContext context;

  const _LinkCard({required this.link, required this.context});

  Future<void> _launchUrl(FtpLink link) async {
    try {
      final url = Uri.parse(link.url);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch ${link.url}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching URL: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            FontAwesomeIcons.server,
            color: AppTheme.success,
            size: 20,
          ),
        ),
        title: Text(link.url),
        subtitle: Text(
          'Response time: ${link.responseTime}ms',
          style: TextStyle(color: AppTheme.success),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => _launchUrl(link),
          color: AppTheme.primary,
        ),
      ),
    );
  }
}

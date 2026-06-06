import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/llm/domain/llm_cancellation.dart';
import '../domain/scraped_book.dart';

/// Manages Node.js subprocess execution for Puppeteer-based scraper scripts.
///
/// Path resolution strategy:
/// - **Development**: Uses system `node` from PATH, scripts from project's
///   `assets/scrapers/` directory (override via constructor).
/// - **Production (macOS)**: Bundled node binary and scripts inside
///   `Bundle.main.resourcePath`.
/// - **Production (Windows)**: Bundled in `data/` next to the executable.
class ScraperProcessRunner {
  ScraperProcessRunner({String? nodeExecutable, String? scrapersDir})
    : _nodeExecutableOverride = nodeExecutable,
      _scrapersDirOverride = scrapersDir;

  final String? _nodeExecutableOverride;
  final String? _scrapersDirOverride;

  String? _resolvedNodePath;
  String? _resolvedScrapersDir;

  /// Resolve and cache paths on first use.
  Future<void> ensureInitialized() async {
    if (_resolvedNodePath != null) return;
    _resolvedNodePath = await _resolveNodeExecutable();
    _resolvedScrapersDir = await _resolveScrapersDir();
  }

  /// Run a scraper script and return parsed [ScrapedBook] results.
  ///
  /// [scriptName] is the filename (e.g. 'qidian_scraper.js').
  /// [args] are optional CLI arguments passed to the script.
  /// Throws [ScraperException] on process failure or invalid output.
  /// Throws [CdpRequiredException] when the script exits with code 2
  /// (Chrome DevTools Protocol not available).
  Future<List<ScrapedBook>> run(
    String scriptName, {
    List<String> args = const [],
    Duration timeout = const Duration(minutes: 5),
    LlmCancellationToken? cancellationToken,
  }) async {
    await ensureInitialized();
    cancellationToken?.throwIfCancelled();

    final nodePath = _resolvedNodePath!;
    final scriptPath = p.join(_resolvedScrapersDir!, scriptName);

    if (!File(scriptPath).existsSync()) {
      throw ScraperException('Scraper script not found: $scriptPath');
    }

    // Set NODE_PATH so require() finds node_modules even when scripts
    // run from flutter_assets/ (which doesn't contain node_modules).
    final nodeModulesDir = await _resolveNodeModulesDir();
    final env = <String, String>{...Platform.environment};
    if (nodeModulesDir != null) {
      env['NODE_PATH'] = nodeModulesDir;
    }

    final process = await Process.start(nodePath, [
      scriptPath,
      ...args,
    ], environment: env);

    final stdoutFuture = process.stdout.transform(utf8.decoder).join();
    final stderrFuture = process.stderr.transform(utf8.decoder).join();

    final timeoutCompleter = Completer<int>();
    final timeoutTimer = Timer(timeout, () {
      process.kill();
      timeoutCompleter.completeError(
        ScraperException(
          'Scraper $scriptName timed out after ${timeout.inMinutes} minutes.',
        ),
      );
    });

    StreamSubscription<void>? cancellationSubscription;
    Future<int>? cancellationFuture;
    if (cancellationToken != null) {
      final cancellationCompleter = Completer<int>();
      cancellationSubscription = cancellationToken.onCancel.listen((_) {
        process.kill();
        if (!cancellationCompleter.isCompleted) {
          cancellationCompleter.completeError(
            const LlmCancellationException('市场扫描任务已取消。'),
          );
        }
      });
      cancellationFuture = cancellationCompleter.future;
    }

    late final int exitCode;
    try {
      exitCode = await Future.any([
        process.exitCode,
        timeoutCompleter.future,
        ?cancellationFuture,
      ]);
    } on Object {
      await _drainAfterKill(process, stdoutFuture, stderrFuture);
      rethrow;
    } finally {
      timeoutTimer.cancel();
      await cancellationSubscription?.cancel();
    }

    final stdout = (await stdoutFuture).trim();
    final stderr = (await stderrFuture).trim();

    // Exit code 2 = CDP not available (set by cdp-helper.js).
    if (exitCode == 2) {
      throw CdpRequiredException(stderr);
    }

    if (exitCode != 0) {
      throw ScraperException(
        'Scraper $scriptName exited with code $exitCode: $stderr',
      );
    }

    cancellationToken?.throwIfCancelled();
    if (stdout.isEmpty) {
      return const [];
    }

    return _parseOutput(stdout, scriptName);
  }

  /// Check if Chrome DevTools Protocol is available at the default endpoint.
  Future<bool> checkCdpAvailable({
    String endpoint = 'http://127.0.0.1:9222',
  }) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);
      final request = await client.getUrl(Uri.parse('$endpoint/json/version'));
      final response = await request.close();
      client.close();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Ensure Chrome is running with CDP enabled. If no Chrome is listening on
  /// port 9222, auto-launch one as a detached process and wait until it's ready.
  ///
  /// Returns `true` if CDP is available (either already running or auto-launched).
  /// Returns `false` if Chrome could not be found or launched.
  Future<bool> ensureCdpReady({
    int port = 9222,
    Duration launchTimeout = const Duration(seconds: 15),
    LlmCancellationToken? cancellationToken,
  }) async {
    cancellationToken?.throwIfCancelled();
    // Already available — nothing to do.
    if (await checkCdpAvailable()) return true;

    final chromePath = _findChromeBinary();
    if (chromePath == null) {
      return false;
    }

    try {
      await Process.start(chromePath, [
        '--headless=new',
        '--remote-debugging-port=$port',
        '--no-first-run',
        '--no-default-browser-check',
        '--disable-extensions',
        '--disable-gpu',
        '--user-data-dir=${await _chromeUserDataDir()}',
      ], mode: ProcessStartMode.detached);
    } catch (e) {
      return false;
    }

    // Poll until CDP is ready or timeout.
    final deadline = DateTime.now().add(launchTimeout);
    while (DateTime.now().isBefore(deadline)) {
      cancellationToken?.throwIfCancelled();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (await checkCdpAvailable()) {
        return true;
      }
    }

    return false;
  }

  /// Locate Chrome/Chromium binary on the system.
  String? _findChromeBinary() {
    if (Platform.isMacOS) {
      final candidates = [
        '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
        '/Applications/Chromium.app/Contents/MacOS/Chromium',
        '/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary',
      ];
      for (final path in candidates) {
        if (File(path).existsSync()) return path;
      }
      // Try `mdfind` as a last resort.
      try {
        final result = Process.runSync('mdfind', [
          'kMDItemCFBundleIdentifier == "com.google.Chrome"',
        ]);
        if (result.exitCode == 0) {
          final appPath = (result.stdout as String)
              .trim()
              .split('\n')
              .first
              .trim();
          if (appPath.isNotEmpty) {
            final binary = p.join(
              appPath,
              'Contents',
              'MacOS',
              'Google Chrome',
            );
            if (File(binary).existsSync()) return binary;
          }
        }
      } catch (_) {}
    } else if (Platform.isWindows) {
      final programFiles =
          Platform.environment['ProgramFiles'] ?? r'C:\Program Files';
      final programFilesX86 =
          Platform.environment['ProgramFiles(x86)'] ??
          r'C:\Program Files (x86)';
      final localAppData = Platform.environment['LOCALAPPDATA'] ?? '';
      final candidates = [
        p.join(programFiles, 'Google', 'Chrome', 'Application', 'chrome.exe'),
        p.join(
          programFilesX86,
          'Google',
          'Chrome',
          'Application',
          'chrome.exe',
        ),
        if (localAppData.isNotEmpty)
          p.join(localAppData, 'Google', 'Chrome', 'Application', 'chrome.exe'),
      ];
      for (final path in candidates) {
        if (File(path).existsSync()) return path;
      }
    }
    return null;
  }

  /// Dedicated user-data-dir so the auto-launched Chrome does not interfere
  /// with the user's default profile.
  Future<String> _chromeUserDataDir() async {
    final supportDir = await getApplicationSupportDirectory();
    final dir = Directory(p.join(supportDir.path, 'chrome-cdp-profile'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir.path;
  }

  List<ScrapedBook> _parseOutput(String stdout, String scriptName) {
    try {
      final decoded = jsonDecode(stdout);
      if (decoded is! List) {
        throw ScraperException(
          'Scraper $scriptName output is not a JSON array.',
        );
      }
      return decoded
          .cast<Map<String, Object?>>()
          .map(ScrapedBook.fromJson)
          .toList(growable: false);
    } on FormatException catch (e) {
      throw ScraperException(
        'Scraper $scriptName output is not valid JSON: $e',
      );
    }
  }

  Future<String> _resolveNodeExecutable() async {
    if (_nodeExecutableOverride != null) {
      return _nodeExecutableOverride;
    }

    // Check for bundled Node.js in app resources.
    final bundledNode = await _findBundledNode();
    if (bundledNode != null) {
      return bundledNode;
    }

    // Fallback to system node.
    final systemNode = await _findSystemNode();
    if (systemNode != null) {
      return systemNode;
    }

    throw const ScraperException(
      'Node.js not found. Install Node.js or bundle it with the app.',
    );
  }

  Future<String?> _findBundledNode() async {
    if (Platform.isMacOS) {
      // macOS: node binary in app bundle Resources.
      final supportDir = await getApplicationSupportDirectory();
      final bundledPath = p.join(supportDir.parent.path, 'Resources', 'node');
      if (File(bundledPath).existsSync()) {
        return bundledPath;
      }
      // Also check inside .app bundle.
      final executableDir = p.dirname(Platform.resolvedExecutable);
      final appBundleNode = p.join(executableDir, '..', 'Resources', 'node');
      final normalized = p.normalize(appBundleNode);
      if (File(normalized).existsSync()) {
        return normalized;
      }
    } else if (Platform.isWindows) {
      final executableDir = p.dirname(Platform.resolvedExecutable);
      final bundledPath = p.join(executableDir, 'data', 'node.exe');
      if (File(bundledPath).existsSync()) {
        return bundledPath;
      }
    }
    return null;
  }

  Future<String?> _findSystemNode() async {
    // 1. Try `which node` (works when running from terminal with PATH set).
    try {
      final result = await Process.run(Platform.isWindows ? 'where' : 'which', [
        'node',
      ]);
      if (result.exitCode == 0) {
        final path = (result.stdout as String).trim().split('\n').first.trim();
        if (path.isNotEmpty && File(path).existsSync()) {
          return path;
        }
      }
    } catch (_) {}

    // 2. Search common node locations (macOS GUI apps don't inherit shell PATH
    //    from nvm, fnm, volta, or homebrew).
    if (Platform.isMacOS) {
      final home = Platform.environment['HOME'] ?? '';
      final directPaths = [
        '/opt/homebrew/bin/node',
        '/usr/local/bin/node',
        if (home.isNotEmpty) ...['$home/.volta/bin/node'],
      ];
      for (final path in directPaths) {
        if (File(path).existsSync()) return path;
      }

      // NVM: pick the latest installed version.
      final nvmNode = _findVersionedNode(
        home.isNotEmpty ? '$home/.nvm/versions/node' : null,
        'node',
      );
      if (nvmNode != null) return nvmNode;
    }

    return null;
  }

  /// Walk a version-manager directory (nvm, fnm, …) and return the node
  /// binary from the highest-versioned sub-directory, or null.
  String? _findVersionedNode(String? versionsDir, String binaryName) {
    if (versionsDir == null) return null;
    final dir = Directory(versionsDir);
    if (!dir.existsSync()) return null;

    String? best;
    for (final entry in dir.listSync()) {
      if (entry is! Directory) continue;
      final candidate = p.join(entry.path, 'bin', binaryName);
      if (File(candidate).existsSync()) best = candidate;
    }
    return best;
  }

  Future<String> _resolveScrapersDir() async {
    if (_scrapersDirOverride != null) {
      return _scrapersDirOverride;
    }

    if (Platform.isMacOS) {
      final executableDir = p.dirname(Platform.resolvedExecutable);

      // Production: bundled in Resources/scrapers/ (via prepare script).
      final resourcesScrapers = p.normalize(
        p.join(executableDir, '..', 'Resources', 'scrapers'),
      );
      if (Directory(resourcesScrapers).existsSync()) {
        return resourcesScrapers;
      }

      // Fallback: Flutter asset bundle (scrapers declared in pubspec.yaml).
      final flutterAssetsScrapers = p.normalize(
        p.join(
          executableDir,
          '..',
          'Frameworks',
          'App.framework',
          'Versions',
          'A',
          'Resources',
          'flutter_assets',
          'assets',
          'scrapers',
        ),
      );
      if (Directory(flutterAssetsScrapers).existsSync()) {
        return flutterAssetsScrapers;
      }
    } else if (Platform.isWindows) {
      final executableDir = p.dirname(Platform.resolvedExecutable);
      final bundledDir = p.join(executableDir, 'data', 'scrapers');
      if (Directory(bundledDir).existsSync()) {
        return bundledDir;
      }
    }

    // Development fallback: project assets directory.
    final projectRoot = await _findProjectRoot();
    if (projectRoot != null) {
      return p.join(projectRoot, 'assets', 'scrapers');
    }

    throw const ScraperException('Scrapers directory not found.');
  }

  Future<String?> _findProjectRoot() async {
    // Walk up from the working directory looking for pubspec.yaml.
    var dir = Directory.current;
    for (var i = 0; i < 10; i++) {
      if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
        return dir.path;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    return null;
  }

  /// Find the node_modules directory for scraper dependencies.
  /// Searches: scrapers dir itself, then project root's scrapers dir.
  Future<String?> _resolveNodeModulesDir() async {
    // 1. Directly inside the scrapers directory (development / production bundle).
    final inlineModules = p.join(_resolvedScrapersDir!, 'node_modules');
    if (Directory(inlineModules).existsSync()) return inlineModules;

    // 2. Project's assets/scrapers/node_modules (when scripts run from flutter_assets).
    final projectRoot = await _findProjectRoot();
    if (projectRoot != null) {
      final projectModules = p.join(
        projectRoot,
        'assets',
        'scrapers',
        'node_modules',
      );
      if (Directory(projectModules).existsSync()) return projectModules;
    }

    return null;
  }

  Future<void> _drainAfterKill(
    Process process,
    Future<String> stdoutFuture,
    Future<String> stderrFuture,
  ) async {
    try {
      await process.exitCode.timeout(
        const Duration(seconds: 2),
        onTimeout: () => -1,
      );
      await Future.wait([
        stdoutFuture.catchError((_) => ''),
        stderrFuture.catchError((_) => ''),
      ]);
    } on Object {
      // Best-effort cleanup after a cancelled or timed-out subprocess.
    }
  }
}

class ScraperException implements Exception {
  const ScraperException(this.message);
  final String message;

  @override
  String toString() => 'ScraperException: $message';
}

/// Thrown when a scraper requires Chrome DevTools Protocol but it's not available.
/// The Dart side should prompt the user to start Chrome in debug mode.
class CdpRequiredException implements Exception {
  const CdpRequiredException(this.message);
  final String message;

  @override
  String toString() => 'CdpRequiredException: $message';
}

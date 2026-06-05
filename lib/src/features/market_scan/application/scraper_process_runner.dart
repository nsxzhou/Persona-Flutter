import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  ScraperProcessRunner({
    String? nodeExecutable,
    String? scrapersDir,
  })  : _nodeExecutableOverride = nodeExecutable,
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
  Future<List<ScrapedBook>> run(
    String scriptName, {
    List<String> args = const [],
    Duration timeout = const Duration(minutes: 5),
  }) async {
    await ensureInitialized();

    final nodePath = _resolvedNodePath!;
    final scriptPath = p.join(_resolvedScrapersDir!, scriptName);

    if (!File(scriptPath).existsSync()) {
      throw ScraperException('Scraper script not found: $scriptPath');
    }

    final result = await Process.run(
      nodePath,
      [scriptPath, ...args],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ).timeout(timeout, onTimeout: () {
      throw ScraperException(
        'Scraper $scriptName timed out after ${timeout.inMinutes} minutes.',
      );
    });

    if (result.exitCode != 0) {
      final stderr = (result.stderr as String).trim();
      throw ScraperException(
        'Scraper $scriptName exited with code ${result.exitCode}: $stderr',
      );
    }

    final stdout = (result.stdout as String).trim();
    if (stdout.isEmpty) {
      return const [];
    }

    return _parseOutput(stdout, scriptName);
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
      final appBundleNode = p.join(
        executableDir,
        '..',
        'Resources',
        'node',
      );
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
    try {
      final result = await Process.run(
        Platform.isWindows ? 'where' : 'which',
        ['node'],
      );
      if (result.exitCode == 0) {
        final path = (result.stdout as String).trim().split('\n').first.trim();
        if (path.isNotEmpty && File(path).existsSync()) {
          return path;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<String> _resolveScrapersDir() async {
    if (_scrapersDirOverride != null) {
      return _scrapersDirOverride;
    }

    // Check bundled scripts in app resources.
    if (Platform.isMacOS) {
      final executableDir = p.dirname(Platform.resolvedExecutable);
      final appBundleDir = p.normalize(
        p.join(executableDir, '..', 'Resources', 'scrapers'),
      );
      if (Directory(appBundleDir).existsSync()) {
        return appBundleDir;
      }
    } else if (Platform.isWindows) {
      final executableDir = p.dirname(Platform.resolvedExecutable);
      final bundledDir = p.join(executableDir, 'data', 'scrapers');
      if (Directory(bundledDir).existsSync()) {
        return bundledDir;
      }
    }

    // Fallback: project assets directory (development).
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
}

class ScraperException implements Exception {
  const ScraperException(this.message);
  final String message;

  @override
  String toString() => 'ScraperException: $message';
}

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import '../../config.dart';

/// Error thrown when loading `spry.config.dart` fails.
final class LoadConfigException implements Exception {
  /// Creates a config loading exception with a human-readable [message].
  const LoadConfigException(this.message);

  /// Human-readable error description.
  final String message;

  @override
  String toString() => 'LoadConfigException: $message';
}

/// Build-time configuration for generating and serving a Spry app.
final class BuildConfig {
  /// Creates a build configuration.
  const BuildConfig({
    required this.rootDir,
    this.host = '0.0.0.0',
    this.port = 3000,
    this.target = BuildTarget.dart,
    this.routesDir = 'routes',
    this.middlewareDir = 'middleware',
    this.publicDir = 'public',
    this.outputDir = '.spry',
    this.reload = ReloadStrategy.restart,
    this.wranglerConfig,
  });

  /// Creates a build configuration from JSON emitted by `spry.config.dart`.
  factory BuildConfig.fromJson(
    Map<String, dynamic> json, {
    required String rootDir,
  }) {
    return BuildConfig(
      rootDir: rootDir,
      host: _string(json['host']) ?? '0.0.0.0',
      port: _int(json['port']) ?? 3000,
      target: _buildTarget(json['target']) ?? BuildTarget.dart,
      routesDir: _string(json['routesDir']) ?? 'routes',
      middlewareDir: _string(json['middlewareDir']) ?? 'middleware',
      publicDir: _string(json['publicDir']) ?? 'public',
      outputDir: _string(json['outputDir']) ?? '.spry',
      reload: _reloadStrategy(json['reload']) ?? ReloadStrategy.restart,
      wranglerConfig: _string(json['wranglerConfig']),
    );
  }

  /// Absolute project root directory.
  final String rootDir;

  /// Host used by `spry serve`.
  final String host;

  /// Port used by `spry serve`.
  final int port;

  /// Target runtime.
  final BuildTarget target;

  /// Routes directory relative to [rootDir].
  final String routesDir;

  /// Middleware directory relative to [rootDir].
  final String middlewareDir;

  /// Public asset directory relative to [rootDir].
  final String publicDir;

  /// Generated output directory relative to [rootDir].
  final String outputDir;

  /// Reload strategy used by `spry serve`.
  final ReloadStrategy reload;

  /// Optional Wrangler config path.
  final String? wranglerConfig;

  /// Returns a copy with selected fields replaced.
  BuildConfig copyWith({
    String? rootDir,
    String? host,
    int? port,
    BuildTarget? target,
    String? routesDir,
    String? middlewareDir,
    String? publicDir,
    String? outputDir,
    ReloadStrategy? reload,
    String? wranglerConfig,
  }) {
    return BuildConfig(
      rootDir: rootDir ?? this.rootDir,
      host: host ?? this.host,
      port: port ?? this.port,
      target: target ?? this.target,
      routesDir: routesDir ?? this.routesDir,
      middlewareDir: middlewareDir ?? this.middlewareDir,
      publicDir: publicDir ?? this.publicDir,
      outputDir: outputDir ?? this.outputDir,
      reload: reload ?? this.reload,
      wranglerConfig: wranglerConfig ?? this.wranglerConfig,
    );
  }

  /// Applies JSON-like [overrides] onto this configuration.
  BuildConfig merge(Map<String, dynamic> overrides) {
    return copyWith(
      rootDir: _string(overrides['rootDir']),
      host: _string(overrides['host']),
      port: _int(overrides['port']),
      target: _buildTarget(overrides['target']),
      routesDir: _string(overrides['routesDir']),
      middlewareDir: _string(overrides['middlewareDir']),
      publicDir: _string(overrides['publicDir']),
      outputDir: _string(overrides['outputDir']),
      reload: _reloadStrategy(overrides['reload']),
      wranglerConfig: _string(overrides['wranglerConfig']),
    );
  }
}

/// Loads `spry.config.dart` and merges the supplied [overrides].
Future<BuildConfig> loadConfig({
  String? configPath,
  Map<String, dynamic> overrides = const {},
}) async {
  final rootDir = p.normalize(
    p.absolute(_string(overrides['rootDir']) ?? Directory.current.path),
  );
  final file = File(
    p.normalize(p.absolute(rootDir, configPath ?? 'spry.config.dart')),
  );

  var config = BuildConfig(rootDir: rootDir);
  if (await file.exists()) {
    final result = await Process.run(Platform.resolvedExecutable, [
      'run',
      file.path,
    ], workingDirectory: rootDir);

    if (result.exitCode != 0) {
      throw LoadConfigException(
        'Failed to run spry.config.dart:\n${result.stderr}',
      );
    }

    final stdoutText = (result.stdout as String).trim();
    if (stdoutText.isEmpty) {
      throw const LoadConfigException(
        'spry.config.dart did not emit any configuration JSON.',
      );
    }

    final json = jsonDecode(stdoutText);
    if (json is! Map<String, dynamic>) {
      throw const LoadConfigException(
        'spry.config.dart must emit a JSON object.',
      );
    }

    config = BuildConfig.fromJson(json, rootDir: rootDir);
  }

  return config.merge(overrides);
}

String? _string(Object? value) {
  return switch (value) {
    null => null,
    String() => value,
    _ => '$value',
  };
}

int? _int(Object? value) {
  return switch (value) {
    null => null,
    int() => value,
    num() => value.toInt(),
    String() => int.tryParse(value),
    _ => null,
  };
}

BuildTarget? _buildTarget(Object? value) {
  return switch (value) {
    null => null,
    BuildTarget() => value,
    String() => BuildTarget.values.where((it) => it.name == value).firstOrNull,
    _ => null,
  };
}

ReloadStrategy? _reloadStrategy(Object? value) {
  return switch (value) {
    null => null,
    ReloadStrategy() => value,
    String() =>
      ReloadStrategy.values.where((it) => it.name == value).firstOrNull,
    _ => null,
  };
}

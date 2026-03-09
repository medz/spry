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
      host: _readString(json, 'host') ?? '0.0.0.0',
      port: _readInt(json, 'port') ?? 3000,
      target: _readBuildTarget(json, 'target') ?? BuildTarget.dart,
      routesDir: _readString(json, 'routesDir') ?? 'routes',
      middlewareDir: _readString(json, 'middlewareDir') ?? 'middleware',
      publicDir: _readString(json, 'publicDir') ?? 'public',
      outputDir: _readString(json, 'outputDir') ?? '.spry',
      reload:
          _readReloadStrategy(json, 'reload') ?? ReloadStrategy.restart,
      wranglerConfig: _readNullableString(json, 'wranglerConfig'),
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
    Object? wranglerConfig = _unset,
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
      wranglerConfig: switch (wranglerConfig) {
        _Unset() => this.wranglerConfig,
        String() => wranglerConfig,
        null => null,
        _ => throw ArgumentError.value(
          wranglerConfig,
          'wranglerConfig',
          'must be a string or null',
        ),
      },
    );
  }

  /// Applies JSON-like [overrides] onto this configuration.
  BuildConfig merge(Map<String, dynamic> overrides) {
    return BuildConfig(
      rootDir: _readString(overrides, 'rootDir') ?? rootDir,
      host: _readString(overrides, 'host') ?? host,
      port: _readInt(overrides, 'port') ?? port,
      target: _readBuildTarget(overrides, 'target') ?? target,
      routesDir: _readString(overrides, 'routesDir') ?? routesDir,
      middlewareDir:
          _readString(overrides, 'middlewareDir') ?? middlewareDir,
      publicDir: _readString(overrides, 'publicDir') ?? publicDir,
      outputDir: _readString(overrides, 'outputDir') ?? outputDir,
      reload: _readReloadStrategy(overrides, 'reload') ?? reload,
      wranglerConfig: overrides.containsKey('wranglerConfig')
          ? _readNullableString(overrides, 'wranglerConfig')
          : wranglerConfig,
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

const _unset = _Unset();

final class _Unset {
  const _Unset();
}

String? _readString(Map<String, dynamic> source, String key) {
  if (!source.containsKey(key)) {
    return null;
  }

  final value = source[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  throw LoadConfigException(
    'Invalid `$key`: expected a string, got ${_describeValue(value)}.',
  );
}

String? _readNullableString(Map<String, dynamic> source, String key) {
  if (!source.containsKey(key)) {
    return null;
  }
  return _readString(source, key);
}

int? _readInt(Map<String, dynamic> source, String key) {
  if (!source.containsKey(key)) {
    return null;
  }

  final value = source[key];
  final parsed = switch (value) {
    null => null,
    int() => value,
    num() when value == value.roundToDouble() => value.toInt(),
    String() => int.tryParse(value),
    _ => null,
  };
  if (parsed != null) {
    return parsed;
  }
  throw LoadConfigException(
    'Invalid `$key`: expected an integer, got ${_describeValue(value)}.',
  );
}

BuildTarget? _readBuildTarget(Map<String, dynamic> source, String key) {
  if (!source.containsKey(key)) {
    return null;
  }

  final value = source[key];
  final parsed = _buildTarget(value);
  if (parsed != null) {
    return parsed;
  }
  throw LoadConfigException(
    'Invalid `$key`: expected one of ${BuildTarget.values.map((it) => it.name).join(', ')}, got ${_describeValue(value)}.',
  );
}

ReloadStrategy? _readReloadStrategy(Map<String, dynamic> source, String key) {
  if (!source.containsKey(key)) {
    return null;
  }

  final value = source[key];
  final parsed = _reloadStrategy(value);
  if (parsed != null) {
    return parsed;
  }
  throw LoadConfigException(
    'Invalid `$key`: expected one of ${ReloadStrategy.values.map((it) => it.name).join(', ')}, got ${_describeValue(value)}.',
  );
}

String _describeValue(Object? value) {
  if (value == null) {
    return 'null';
  }
  return '$value (${value.runtimeType})';
}

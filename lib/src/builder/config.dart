import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import '../../config.dart';

final class LoadConfigException implements Exception {
  const LoadConfigException(this.message);

  final String message;

  @override
  String toString() => 'LoadConfigException: $message';
}

final class BuildConfig {
  const BuildConfig({
    required this.rootDir,
    this.host = '0.0.0.0',
    this.port = 3000,
    this.target = BuildTarget.dart,
    this.routesDir = 'routes',
    this.middlewareDir = 'middleware',
    this.outputDir = '.spry',
    this.reload = ReloadStrategy.restart,
  });

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
      outputDir: _string(json['outputDir']) ?? '.spry',
      reload: _reloadStrategy(json['reload']) ?? ReloadStrategy.restart,
    );
  }

  final String rootDir;
  final String host;
  final int port;
  final BuildTarget target;
  final String routesDir;
  final String middlewareDir;
  final String outputDir;
  final ReloadStrategy reload;

  BuildConfig copyWith({
    String? rootDir,
    String? host,
    int? port,
    BuildTarget? target,
    String? routesDir,
    String? middlewareDir,
    String? outputDir,
    ReloadStrategy? reload,
  }) {
    return BuildConfig(
      rootDir: rootDir ?? this.rootDir,
      host: host ?? this.host,
      port: port ?? this.port,
      target: target ?? this.target,
      routesDir: routesDir ?? this.routesDir,
      middlewareDir: middlewareDir ?? this.middlewareDir,
      outputDir: outputDir ?? this.outputDir,
      reload: reload ?? this.reload,
    );
  }

  BuildConfig merge(Map<String, dynamic> overrides) {
    return copyWith(
      rootDir: _string(overrides['rootDir']),
      host: _string(overrides['host']),
      port: _int(overrides['port']),
      target: _buildTarget(overrides['target']),
      routesDir: _string(overrides['routesDir']),
      middlewareDir: _string(overrides['middlewareDir']),
      outputDir: _string(overrides['outputDir']),
      reload: _reloadStrategy(overrides['reload']),
    );
  }
}

Future<BuildConfig> loadConfig({
  Map<String, dynamic> overrides = const {},
}) async {
  final rootDir = p.normalize(
    p.absolute(_string(overrides['rootDir']) ?? Directory.current.path),
  );
  final file = File(p.join(rootDir, 'spry.config.dart'));

  var config = BuildConfig(rootDir: rootDir);
  if (await file.exists()) {
    final result = await Process.run(Platform.resolvedExecutable, [
      'run',
      'spry.config.dart',
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

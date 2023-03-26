import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http_methods/http_methods.dart';
import 'package:path/path.dart';

import 'segment_configuration.dart';

part 'segment.freezed.dart';

/// Path segment.
@freezed
class Segment with _$Segment {
  /// Create a new path segment.
  const factory Segment({
    required String directory,
    String? handler,
    String? middleware,
    required Map<String, Segment> methodSegments,
    required Map<String, String> paramsMiddleware,
    SegmentConfiguration? configuration,
    required Iterable<Segment> children,
  }) = _Segment;

  /// Create a new path segment from a directory path.
  factory Segment.fromDirectory(String directory) {
    final Directory folder = Directory(directory);
    if (!folder.existsSync()) {
      throw FileSystemException('Directory not found', directory);
    }

    return Segment(
      directory: folder.path,
      handler: _findFile(folder, 'handler.dart'),
      middleware: _findFile(folder, 'middleware.dart'),
      paramsMiddleware: _findParamsMiddleware(folder),
      configuration: _findConfiguration(folder),
      children: _findChildren(folder),
      methodSegments: _findMethotSegments(folder),
    );
  }

  /// Find a file in a directory.
  static String? _findFile(Directory directory, String name) {
    final File file = File(join(directory.path, name));

    if (file.existsSync()) {
      return file.path;
    }

    return null;
  }

  /// Is a method segment.
  static String? _isMethodSegment(String path) {
    final RegExp regexp = RegExp('^\\(([a-zA-Z0-9_]+?)\\)\$');
    final RegExpMatch? match = regexp.firstMatch(basename(path));
    final String? method = match?.group(1);

    if (method != null && isHttpMethod(method)) {
      return method;
    }

    return null;
  }

  /// Find a params middleware files in a directory.
  static Map<String, String> _findParamsMiddleware(Directory directory) {
    final RegExp regexp = RegExp('^([a-zA-Z0-9_]+?).middleware.dart\$');
    final Map<String, String> paramsMiddleware = {};
    for (final FileSystemEntity entity in directory.listSync()) {
      // If entity not a file, skip it.
      if (entity.statSync().type != FileSystemEntityType.file) {
        continue;
      }

      // Check if entity is a params middleware file.
      final RegExpMatch? match = regexp.firstMatch(basename(entity.path));
      if (match == null) {
        continue;
      }

      // Add params middleware to map.
      paramsMiddleware[match.group(1)!] = entity.path;
    }

    return paramsMiddleware;
  }

  /// Find a configuration file in a directory.
  static SegmentConfiguration? _findConfiguration(Directory directory) {
    final File file = File(join(directory.path, 'segment.yaml'));
    if (file.existsSync()) {
      return SegmentConfiguration.fromYaml(file.readAsStringSync(),
          uri: file.uri);
    }

    return null;
  }

  /// Find children segments in a directory.
  static Iterable<Segment> _findChildren(Directory directory) {
    final Iterable<FileSystemEntity> entities = directory.listSync();
    final Iterable<Directory> folders = entities
        .where((FileSystemEntity entity) =>
            entity.statSync().type == FileSystemEntityType.directory)
        .where((element) => _isMethodSegment(element.path) == null)
        .map((FileSystemEntity entity) => Directory(entity.path));

    return folders
        .map((Directory folder) => Segment.fromDirectory(folder.path));
  }

  /// Find method segments in a directory.
  static Map<String, Segment> _findMethotSegments(Directory directory) {
    final Iterable<FileSystemEntity> entities = directory.listSync();
    final Iterable<Directory> folders = entities
        .where((FileSystemEntity entity) =>
            entity.statSync().type == FileSystemEntityType.directory)
        .map((FileSystemEntity entity) => Directory(entity.path));

    final Map<String, Segment> methodSegments = {};
    for (final Directory folder in folders) {
      final String? method = _isMethodSegment(folder.path);
      if (method == null) {
        continue;
      }

      methodSegments[method] = Segment.fromDirectory(folder.path);
    }

    return methodSegments;
  }
}

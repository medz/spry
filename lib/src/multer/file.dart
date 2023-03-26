import 'dart:io';

/// Multipart file.
abstract class File extends Stream<List<int>> {
  /// The file basename.
  String get filename;

  /// The file content type.
  ContentType get contentType;
}

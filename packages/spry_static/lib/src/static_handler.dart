import 'dart:io';

/// Spry static handler.
abstract class StaticHandler {
  /// Directory to serve static files from.
  Directory get directory;

  /// Default file to serve when a directory is requested.
  Iterable<String> get defaultFiles;
}

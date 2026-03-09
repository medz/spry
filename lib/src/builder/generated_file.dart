/// A generated file written during `spry build` or `spry serve`.
final class GeneratedFile {
  /// Creates a generated file descriptor.
  const GeneratedFile({
    required this.path,
    required this.content,
    this.rootRelative = false,
    this.writeIfMissing = false,
  });

  /// Relative output path.
  final String path;

  /// File contents.
  final String content;

  /// Whether [path] is relative to the project root instead of the output dir.
  final bool rootRelative;

  /// Whether writing should be skipped when the file already exists.
  final bool writeIfMissing;
}

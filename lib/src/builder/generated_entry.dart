/// Kinds of generated output emitted by the build pipeline.
enum GeneratedEntryType {
  /// Generated framework runtime source such as `src/app.dart`.
  runtimeSource,

  /// Generated OpenAPI artifacts such as `openapi.json`.
  openapiArtifact,

  /// Generated client source artifacts.
  clientSource,

  /// Generated target-specific helper files.
  targetArtifact,

  /// Generated static-copy events.
  staticCopy,
}

/// A generated output event emitted by the build pipeline.
final class GeneratedEntry {
  /// Creates a generated entry descriptor.
  const GeneratedEntry({
    required this.type,
    required this.path,
    required this.content,
    this.rootRelative = false,
    this.writeIfMissing = false,
  });

  /// Generated entry category.
  final GeneratedEntryType type;

  /// Output path relative to the selected write base.
  final String path;

  /// Generated file contents.
  final String content;

  /// Whether [path] is relative to the project root instead of the output dir.
  final bool rootRelative;

  /// Whether writing should be skipped when the target already exists.
  final bool writeIfMissing;
}

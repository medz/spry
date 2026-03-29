import 'config.dart';

import 'generated_file.dart';

/// Kinds of generated output emitted by the transitional stream pipeline.
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

/// A generated output event emitted by the transitional stream pipeline.
final class GeneratedEntry {
  /// Creates a generated entry descriptor.
  const GeneratedEntry({
    required this.type,
    required this.path,
    required this.content,
    this.rootRelative = false,
    this.writeIfMissing = false,
  });

  /// Converts an existing [GeneratedFile] into a typed generated entry.
  factory GeneratedEntry.fromGeneratedFile(
    GeneratedFile file, {
    required GeneratedEntryType type,
  }) {
    return GeneratedEntry(
      type: type,
      path: file.path,
      content: file.content,
      rootRelative: file.rootRelative,
      writeIfMissing: file.writeIfMissing,
    );
  }

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

  /// Converts this generated entry back into the legacy [GeneratedFile] shape.
  GeneratedFile toGeneratedFile() {
    return GeneratedFile(
      path: path,
      content: content,
      rootRelative: rootRelative,
      writeIfMissing: writeIfMissing,
    );
  }
}

/// Infers a best-effort [GeneratedEntryType] for a legacy [GeneratedFile].
GeneratedEntryType generatedEntryTypeForFile(
  GeneratedFile file,
  BuildConfig config,
) {
  if (file.path.startsWith('src/')) {
    return GeneratedEntryType.runtimeSource;
  }

  final openapi = config.openapi;
  if (openapi != null &&
      file.path == openapi.output.path &&
      file.rootRelative) {
    return GeneratedEntryType.openapiArtifact;
  }

  return GeneratedEntryType.targetArtifact;
}

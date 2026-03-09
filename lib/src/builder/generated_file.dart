final class GeneratedFile {
  const GeneratedFile({
    required this.path,
    required this.content,
    this.rootRelative = false,
    this.writeIfMissing = false,
  });

  final String path;
  final String content;
  final bool rootRelative;
  final bool writeIfMissing;
}

import 'package:ht/ht.dart' show Headers;

/// Resolved static asset data returned by a runtime-specific loader.
final class PublicAsset {
  /// Creates a resolved static asset record.
  const PublicAsset({
    this.body,
    required this.headers,
    this.status = 200,
    this.statusText,
    this.url,
    this.redirected = false,
  });

  /// Asset body payload.
  final Object? body;

  /// Response headers for the asset.
  final Headers headers;

  /// HTTP status code.
  final int status;

  /// Optional status text.
  final String? statusText;

  /// Final asset URL.
  final Uri? url;

  /// Whether the asset response was redirected.
  final bool redirected;
}

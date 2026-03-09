import 'package:ht/ht.dart' show Headers;

final class PublicAsset {
  const PublicAsset({
    this.body,
    required this.headers,
    this.status = 200,
    this.statusText,
    this.url,
    this.redirected = false,
  });

  final Object? body;
  final Headers headers;
  final int status;
  final String? statusText;
  final Uri? url;
  final bool redirected;
}

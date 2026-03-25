import 'header.dart';
import 'link.dart';
import 'media_type.dart';
import 'ref.dart';

/// OpenAPI `response` object.
extension type OpenAPIResponse._(Map<String, Object?> _) {
  /// Creates a response object.
  factory OpenAPIResponse({
    required String description,
    Map<String, OpenAPIRef<OpenAPIHeader>>? headers,
    Map<String, OpenAPIMediaType>? content,
    Map<String, OpenAPIRef<OpenAPILink>>? links,
    Map<String, dynamic>? extensions,
  }) => OpenAPIResponse._({
    'description': description,
    'headers': ?headers,
    'content': ?content,
    'links': ?links,
    ...?_prefixExtensions(extensions),
  });
}

Map<String, Object?>? _prefixExtensions(Map<String, dynamic>? extensions) {
  if (extensions == null) {
    return null;
  }
  return {
    for (final entry in extensions.entries) 'x-${entry.key}': entry.value,
  };
}

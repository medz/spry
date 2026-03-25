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
    ...?switch (headers) {
      final value? => {'headers': value},
      null => null,
    },
    ...?switch (content) {
      final value? => {'content': value},
      null => null,
    },
    ...?switch (links) {
      final value? => {'links': value},
      null => null,
    },
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

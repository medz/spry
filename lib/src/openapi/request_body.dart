import 'media_type.dart';

/// OpenAPI `request-body` object.
extension type OpenAPIRequestBody._(Map<String, Object?> _) {
  /// Creates a request body object.
  factory OpenAPIRequestBody({
    required Map<String, OpenAPIMediaType> content,
    String? description,
    bool? required,
    Map<String, dynamic>? extensions,
  }) => OpenAPIRequestBody._({
    'content': content,
    ...?switch (description) {
      final value? => {'description': value},
      null => null,
    },
    ...?switch (required) {
      final value? => {'required': value},
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

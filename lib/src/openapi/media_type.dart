import 'schema.dart';

/// OpenAPI `media-type` object.
extension type OpenAPIMediaType._(Map<String, Object?> _) {
  /// Creates a media type object.
  factory OpenAPIMediaType({
    OpenAPISchema? schema,
    Object? example,
    Map<String, Object?>? examples,
    Map<String, OpenAPIEncoding>? encoding,
    Map<String, dynamic>? extensions,
  }) {
    _validateExampleFields(
      example: example,
      examples: examples,
      scope: 'OpenAPIMediaType',
    );
    return OpenAPIMediaType._({
      ...?switch (schema) {
        final value? => {'schema': value},
        null => null,
      },
      ...?switch (example) {
        final value? => {'example': value},
        null => null,
      },
      ...?switch (examples) {
        final value? => {'examples': value},
        null => null,
      },
      ...?switch (encoding) {
        final value? => {'encoding': value},
        null => null,
      },
      ...?_prefixExtensions(extensions),
    });
  }
}

/// OpenAPI `encoding` object.
extension type OpenAPIEncoding._(Map<String, Object?> _) {
  /// Creates an encoding object.
  factory OpenAPIEncoding({
    String? contentType,
    Map<String, Object?>? headers,
    String? style,
    bool? explode,
    bool? allowReserved,
    Map<String, dynamic>? extensions,
  }) => OpenAPIEncoding._({
    ...?switch (contentType) {
      final value? => {'contentType': value},
      null => null,
    },
    ...?switch (headers) {
      final value? => {'headers': value},
      null => null,
    },
    ...?switch (style) {
      final value? => {'style': value},
      null => null,
    },
    ...?switch (explode) {
      final value? => {'explode': value},
      null => null,
    },
    ...?switch (allowReserved) {
      final value? => {'allowReserved': value},
      null => null,
    },
    ...?_prefixExtensions(extensions),
  });
}

void _validateExampleFields({
  required Object? example,
  required Map<String, Object?>? examples,
  required String scope,
}) {
  if (example != null && examples != null) {
    throw ArgumentError(
      '$scope.example and $scope.examples are mutually exclusive.',
    );
  }
}

Map<String, Object?>? _prefixExtensions(Map<String, dynamic>? extensions) {
  if (extensions == null) {
    return null;
  }
  return {
    for (final entry in extensions.entries) 'x-${entry.key}': entry.value,
  };
}

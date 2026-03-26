import '_openapi_utils.dart';
import 'example.dart';
import 'header.dart';
import 'ref.dart';
import 'schema.dart';

/// OpenAPI `media-type` object.
extension type OpenAPIMediaType._(Map<String, Object?> _) {
  /// Creates a media type object.
  factory OpenAPIMediaType({
    OpenAPISchema? schema,
    Object? example,
    Map<String, OpenAPIRef<OpenAPIExample>>? examples,
    Map<String, OpenAPIEncoding>? encoding,
    Map<String, Object?>? extensions,
  }) {
    validateExampleMutualExclusivity(
      example: example,
      examples: examples,
      scope: 'OpenAPIMediaType',
    );
    return OpenAPIMediaType._({
      'schema': ?schema,
      'example': ?example,
      'examples': ?examples,
      'encoding': ?encoding,
      ...?prefixExtensions(extensions),
    });
  }
}

/// OpenAPI `encoding` object.
extension type OpenAPIEncoding._(Map<String, Object?> _) {
  /// Creates an encoding object.
  factory OpenAPIEncoding({
    String? contentType,
    Map<String, OpenAPIRef<OpenAPIHeader>>? headers,
    String? style,
    bool? explode,
    bool? allowReserved,
    Map<String, Object?>? extensions,
  }) => OpenAPIEncoding._({
    'contentType': ?contentType,
    'headers': ?headers,
    'style': ?style,
    'explode': ?explode,
    'allowReserved': ?allowReserved,
    ...?prefixExtensions(extensions),
  });
}

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
    Map<String, dynamic>? extensions,
  }) {
    _validateExampleFields(
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
    Map<String, dynamic>? extensions,
  }) => OpenAPIEncoding._({
    'contentType': ?contentType,
    'headers': ?headers,
    'style': ?style,
    'explode': ?explode,
    'allowReserved': ?allowReserved,
    ...?prefixExtensions(extensions),
  });
}

void _validateExampleFields({
  required Object? example,
  required Map<String, OpenAPIRef<OpenAPIExample>>? examples,
  required String scope,
}) {
  if (example != null && examples != null) {
    throw ArgumentError(
      '$scope.example and $scope.examples are mutually exclusive.',
    );
  }
}

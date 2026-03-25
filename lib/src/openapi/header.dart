import '_openapi_utils.dart';
import 'example.dart';
import 'media_type.dart';
import 'ref.dart';
import 'schema.dart';

/// OpenAPI `header` object.
extension type OpenAPIHeader._(Map<String, Object?> _) {
  /// Creates a header object.
  factory OpenAPIHeader({
    String? description,
    bool? required,
    bool? deprecated,
    OpenAPISchema? schema,
    Map<String, OpenAPIMediaType>? content,
    String? style,
    bool? explode,
    Object? example,
    Map<String, OpenAPIRef<OpenAPIExample>>? examples,
    Map<String, dynamic>? extensions,
  }) {
    _validateSchemaOrContent(
      schema: schema,
      content: content,
      scope: 'OpenAPIHeader',
    );
    _validateExampleOrExamples(
      example: example,
      examples: examples,
      scope: 'OpenAPIHeader',
    );
    return OpenAPIHeader._({
      'description': ?description,
      'required': ?required,
      'deprecated': ?deprecated,
      'schema': ?schema,
      'content': ?content,
      'style': ?style,
      'explode': ?explode,
      'example': ?example,
      'examples': ?examples,
      ...?prefixExtensions(extensions),
    });
  }
}

void _validateSchemaOrContent({
  required OpenAPISchema? schema,
  required Map<String, OpenAPIMediaType>? content,
  required String scope,
}) {
  if ((schema == null) == (content == null)) {
    throw ArgumentError(
      '$scope requires exactly one of `schema` or `content`.',
    );
  }
  if (content != null && content.length != 1) {
    throw ArgumentError(
      '$scope.content must contain exactly one media type entry.',
    );
  }
}

void _validateExampleOrExamples({
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

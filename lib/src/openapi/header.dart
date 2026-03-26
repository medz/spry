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
    Map<String, Object?>? extensions,
  }) {
    validateSchemaOrContent(
      schema: schema,
      content: content,
      scope: 'OpenAPIHeader',
    );
    validateExampleMutualExclusivity(
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


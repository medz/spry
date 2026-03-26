import '_openapi_utils.dart';
import 'example.dart';
import 'media_type.dart';
import 'ref.dart';
import 'schema.dart';

/// OpenAPI `parameter` object.
extension type OpenAPIParameter._(Map<String, Object?> _) {
  /// Creates a path parameter.
  factory OpenAPIParameter.path(
    String name, {
    OpenAPISchema? schema,
    Map<String, OpenAPIMediaType>? content,
    String? description,
    String? style,
    Map<String, Object?>? extensions,
  }) {
    validateSchemaOrContent(
      schema: schema,
      content: content,
      scope: 'OpenAPIParameter.path',
    );
    return OpenAPIParameter._({
      'name': name,
      'in': 'path',
      'required': true,
      'schema': ?schema,
      'content': ?content,
      'description': ?description,
      'style': ?style,
      ...?prefixExtensions(extensions),
    });
  }

  /// Creates a query parameter.
  factory OpenAPIParameter.query(
    String name, {
    OpenAPISchema? schema,
    Map<String, OpenAPIMediaType>? content,
    bool required = false,
    String? description,
    bool? allowEmptyValue,
    bool? allowReserved,
    String? style,
    bool? explode,
    Object? example,
    Map<String, OpenAPIRef<OpenAPIExample>>? examples,
    Map<String, Object?>? extensions,
  }) {
    validateSchemaOrContent(
      schema: schema,
      content: content,
      scope: 'OpenAPIParameter.query',
    );
    validateExampleMutualExclusivity(
      example: example,
      examples: examples,
      scope: 'OpenAPIParameter.query',
    );
    return OpenAPIParameter._({
      'name': name,
      'in': 'query',
      if (required) 'required': true,
      'schema': ?schema,
      'content': ?content,
      'description': ?description,
      'allowEmptyValue': ?allowEmptyValue,
      'allowReserved': ?allowReserved,
      'style': ?style,
      'explode': ?explode,
      'example': ?example,
      'examples': ?examples,
      ...?prefixExtensions(extensions),
    });
  }

  /// Creates a header parameter.
  factory OpenAPIParameter.header(
    String name, {
    OpenAPISchema? schema,
    Map<String, OpenAPIMediaType>? content,
    bool? required,
    String? description,
    Map<String, Object?>? extensions,
  }) {
    validateSchemaOrContent(
      schema: schema,
      content: content,
      scope: 'OpenAPIParameter.header',
    );
    return OpenAPIParameter._({
      'name': name,
      'in': 'header',
      'required': ?required,
      'schema': ?schema,
      'content': ?content,
      'description': ?description,
      ...?prefixExtensions(extensions),
    });
  }

  /// Creates a cookie parameter.
  factory OpenAPIParameter.cookie(
    String name, {
    OpenAPISchema? schema,
    Map<String, OpenAPIMediaType>? content,
    bool? required,
    String? description,
    Map<String, Object?>? extensions,
  }) {
    validateSchemaOrContent(
      schema: schema,
      content: content,
      scope: 'OpenAPIParameter.cookie',
    );
    return OpenAPIParameter._({
      'name': name,
      'in': 'cookie',
      'required': ?required,
      'schema': ?schema,
      'content': ?content,
      'description': ?description,
      ...?prefixExtensions(extensions),
    });
  }
}

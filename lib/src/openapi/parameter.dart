import 'media_type.dart';
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
    Map<String, dynamic>? extensions,
  }) {
    _validateSchemaOrContent(
      schema: schema,
      content: content,
      scope: 'OpenAPIParameter.path',
    );
    return OpenAPIParameter._({
      'name': name,
      'in': 'path',
      'required': true,
      ...?switch (schema) {
        final value? => {'schema': value},
        null => null,
      },
      ...?switch (content) {
        final value? => {'content': value},
        null => null,
      },
      ...?switch (description) {
        final value? => {'description': value},
        null => null,
      },
      ...?switch (style) {
        final value? => {'style': value},
        null => null,
      },
      ...?_prefixExtensions(extensions),
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
    Map<String, Object?>? examples,
    Map<String, dynamic>? extensions,
  }) {
    _validateSchemaOrContent(
      schema: schema,
      content: content,
      scope: 'OpenAPIParameter.query',
    );
    return OpenAPIParameter._({
      'name': name,
      'in': 'query',
      if (required) 'required': true,
      ...?switch (schema) {
        final value? => {'schema': value},
        null => null,
      },
      ...?switch (content) {
        final value? => {'content': value},
        null => null,
      },
      ...?switch (description) {
        final value? => {'description': value},
        null => null,
      },
      ...?switch (allowEmptyValue) {
        final value? => {'allowEmptyValue': value},
        null => null,
      },
      ...?switch (allowReserved) {
        final value? => {'allowReserved': value},
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
      ...?switch (example) {
        final value? => {'example': value},
        null => null,
      },
      ...?switch (examples) {
        final value? => {'examples': value},
        null => null,
      },
      ...?_prefixExtensions(extensions),
    });
  }

  /// Creates a header parameter.
  factory OpenAPIParameter.header(
    String name, {
    OpenAPISchema? schema,
    Map<String, OpenAPIMediaType>? content,
    bool? required,
    String? description,
    Map<String, dynamic>? extensions,
  }) {
    _validateSchemaOrContent(
      schema: schema,
      content: content,
      scope: 'OpenAPIParameter.header',
    );
    return OpenAPIParameter._({
      'name': name,
      'in': 'header',
      ...?switch (required) {
        final value? => {'required': value},
        null => null,
      },
      ...?switch (schema) {
        final value? => {'schema': value},
        null => null,
      },
      ...?switch (content) {
        final value? => {'content': value},
        null => null,
      },
      ...?switch (description) {
        final value? => {'description': value},
        null => null,
      },
      ...?_prefixExtensions(extensions),
    });
  }

  /// Creates a cookie parameter.
  factory OpenAPIParameter.cookie(
    String name, {
    OpenAPISchema? schema,
    Map<String, OpenAPIMediaType>? content,
    bool? required,
    String? description,
    Map<String, dynamic>? extensions,
  }) {
    _validateSchemaOrContent(
      schema: schema,
      content: content,
      scope: 'OpenAPIParameter.cookie',
    );
    return OpenAPIParameter._({
      'name': name,
      'in': 'cookie',
      ...?switch (required) {
        final value? => {'required': value},
        null => null,
      },
      ...?switch (schema) {
        final value? => {'schema': value},
        null => null,
      },
      ...?switch (content) {
        final value? => {'content': value},
        null => null,
      },
      ...?switch (description) {
        final value? => {'description': value},
        null => null,
      },
      ...?_prefixExtensions(extensions),
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

Map<String, Object?>? _prefixExtensions(Map<String, dynamic>? extensions) {
  if (extensions == null) {
    return null;
  }
  return {
    for (final entry in extensions.entries) 'x-${entry.key}': entry.value,
  };
}

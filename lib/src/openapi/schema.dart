/// OpenAPI / JSON Schema object.
///
/// This is the one OpenAPI type that is not always map-backed: it supports
/// both object schemas and boolean schemas.
extension type OpenAPISchema._(Object _) {
  /// Creates a string schema.
  factory OpenAPISchema.string({
    String? format,
    String? description,
    String? pattern,
    int? minLength,
    int? maxLength,
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._(
    _withAdditional(additional, {
      'type': 'string',
      ...?switch (format) {
        final value? => {'format': value},
        null => null,
      },
      ...?switch (description) {
        final value? => {'description': value},
        null => null,
      },
      ...?switch (pattern) {
        final value? => {'pattern': value},
        null => null,
      },
      ...?switch (minLength) {
        final value? => {'minLength': value},
        null => null,
      },
      ...?switch (maxLength) {
        final value? => {'maxLength': value},
        null => null,
      },
    }),
  );

  /// Creates an integer schema.
  factory OpenAPISchema.integer({
    String? format,
    num? minimum,
    num? maximum,
    String? description,
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._(
    _withAdditional(additional, {
      'type': 'integer',
      ...?switch (format) {
        final value? => {'format': value},
        null => null,
      },
      ...?switch (minimum) {
        final value? => {'minimum': value},
        null => null,
      },
      ...?switch (maximum) {
        final value? => {'maximum': value},
        null => null,
      },
      ...?switch (description) {
        final value? => {'description': value},
        null => null,
      },
    }),
  );

  /// Creates a number schema.
  factory OpenAPISchema.number({
    num? minimum,
    num? maximum,
    String? description,
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._(
    _withAdditional(additional, {
      'type': 'number',
      ...?switch (minimum) {
        final value? => {'minimum': value},
        null => null,
      },
      ...?switch (maximum) {
        final value? => {'maximum': value},
        null => null,
      },
      ...?switch (description) {
        final value? => {'description': value},
        null => null,
      },
    }),
  );

  /// Creates a boolean schema.
  factory OpenAPISchema.boolean({
    String? description,
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._(
    _withAdditional(additional, {
      'type': 'boolean',
      ...?switch (description) {
        final value? => {'description': value},
        null => null,
      },
    }),
  );

  /// Creates a null schema.
  factory OpenAPISchema.null_({
    String? description,
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._(
    _withAdditional(additional, {
      'type': 'null',
      ...?switch (description) {
        final value? => {'description': value},
        null => null,
      },
    }),
  );

  /// Creates a schema that matches everything.
  factory OpenAPISchema.anything() => OpenAPISchema._(true);

  /// Creates a schema that matches nothing.
  factory OpenAPISchema.nothing() => OpenAPISchema._(false);

  /// Creates an object schema.
  factory OpenAPISchema.object(
    Map<String, OpenAPISchema> properties, {
    List<String>? requiredProperties,
    Object? additionalProperties,
    String? description,
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._(
    _withAdditional(additional, {
      'type': 'object',
      'properties': properties,
      ...?switch (requiredProperties) {
        final value? => {'required': value},
        null => null,
      },
      ...?switch (additionalProperties) {
        final value? => {'additionalProperties': value},
        null => null,
      },
      ...?switch (description) {
        final value? => {'description': value},
        null => null,
      },
    }),
  );

  /// Creates an array schema.
  factory OpenAPISchema.array(
    OpenAPISchema items, {
    int? minItems,
    int? maxItems,
    String? description,
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._(
    _withAdditional(additional, {
      'type': 'array',
      'items': items,
      ...?switch (minItems) {
        final value? => {'minItems': value},
        null => null,
      },
      ...?switch (maxItems) {
        final value? => {'maxItems': value},
        null => null,
      },
      ...?switch (description) {
        final value? => {'description': value},
        null => null,
      },
    }),
  );

  /// Creates a `$ref` schema.
  factory OpenAPISchema.ref(String $ref) => OpenAPISchema._({r'$ref': $ref});

  /// Makes a schema nullable using OpenAPI 3.1 `type: [T, 'null']`.
  factory OpenAPISchema.nullable(OpenAPISchema schema) {
    if (schema case final bool value) {
      return value ? OpenAPISchema.anything() : OpenAPISchema.null_();
    }

    final json = schema as Map<String, Object?>;
    final type = json['type'];
    final nullableType = switch (type) {
      final List<Object?> values =>
        values.contains('null') ? values : [...values, 'null'],
      final String value => [value, 'null'],
      null => ['null'],
      _ => ['null'],
    };

    return OpenAPISchema._({...json, 'type': nullableType});
  }

  /// Wraps arbitrary JSON Schema object fields.
  factory OpenAPISchema.additional(Map<String, dynamic> additional) =>
      OpenAPISchema._({...additional});

  /// Creates a `oneOf` schema.
  factory OpenAPISchema.oneOf(
    List<OpenAPISchema> schemas, {
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._(_withAdditional(additional, {'oneOf': schemas}));

  /// Creates an `anyOf` schema.
  factory OpenAPISchema.anyOf(
    List<OpenAPISchema> schemas, {
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._(_withAdditional(additional, {'anyOf': schemas}));

  /// Creates an `allOf` schema.
  factory OpenAPISchema.allOf(
    List<OpenAPISchema> schemas, {
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._(_withAdditional(additional, {'allOf': schemas}));
}

Map<String, Object?> _withAdditional(
  Map<String, dynamic>? additional,
  Map<String, Object?> explicit,
) => {...?additional, ...explicit};

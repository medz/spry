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
  }) => OpenAPISchema._({
    ...?additional,
    'type': 'string',
    'format': ?format,
    'description': ?description,
    'pattern': ?pattern,
    'minLength': ?minLength,
    'maxLength': ?maxLength,
  });

  /// Creates an integer schema.
  factory OpenAPISchema.integer({
    String? format,
    num? minimum,
    num? maximum,
    String? description,
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._({
    ...?additional,
    'type': 'integer',
    'format': ?format,
    'minimum': ?minimum,
    'maximum': ?maximum,
    'description': ?description,
  });

  /// Creates a number schema.
  factory OpenAPISchema.number({
    num? minimum,
    num? maximum,
    String? description,
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._({
    ...?additional,
    'type': 'number',
    'minimum': ?minimum,
    'maximum': ?maximum,
    'description': ?description,
  });

  /// Creates a boolean schema.
  factory OpenAPISchema.boolean({
    String? description,
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._({
    ...?additional,
    'type': 'boolean',
    'description': ?description,
  });

  /// Creates a null schema.
  factory OpenAPISchema.null_({
    String? description,
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._({
    ...?additional,
    'type': 'null',
    'description': ?description,
  });

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
  }) => OpenAPISchema._({
    ...?additional,
    'type': 'object',
    'properties': properties,
    'required': ?requiredProperties,
    'additionalProperties': ?additionalProperties,
    'description': ?description,
  });

  /// Creates an array schema.
  factory OpenAPISchema.array(
    OpenAPISchema items, {
    int? minItems,
    int? maxItems,
    String? description,
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._({
    ...?additional,
    'type': 'array',
    'items': items,
    'minItems': ?minItems,
    'maxItems': ?maxItems,
    'description': ?description,
  });

  /// Creates a `$ref` schema.
  factory OpenAPISchema.ref(String $ref) => OpenAPISchema._({r'$ref': $ref});

  /// Makes a schema nullable using OpenAPI 3.1 `type: [T, 'null']`.
  factory OpenAPISchema.nullable(OpenAPISchema schema) {
    if (schema case final bool value) {
      return value ? OpenAPISchema.anything() : OpenAPISchema.null_();
    }

    final json = schema as Map<String, Object?>;
    final type = json['type'];
    // Schemas without an explicit type ($ref, oneOf, anyOf, allOf, …) must not
    // have a sibling `type` array injected — that produces invalid OpenAPI 3.1.
    // Use anyOf to add null as an alternative instead.
    if (type == null) {
      return OpenAPISchema._({
        'anyOf': [schema, OpenAPISchema.null_()],
      });
    }
    final nullableType = switch (type) {
      final List<Object?> values =>
        values.contains('null') ? values : [...values, 'null'],
      final String value => [value, 'null'],
      _ => [type, 'null'],
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
  }) => OpenAPISchema._({...?additional, 'oneOf': schemas});

  /// Creates an `anyOf` schema.
  factory OpenAPISchema.anyOf(
    List<OpenAPISchema> schemas, {
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._({...?additional, 'anyOf': schemas});

  /// Creates an `allOf` schema.
  factory OpenAPISchema.allOf(
    List<OpenAPISchema> schemas, {
    Map<String, dynamic>? additional,
  }) => OpenAPISchema._({...?additional, 'allOf': schemas});
}

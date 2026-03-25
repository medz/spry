/// Minimal route-side OpenAPI components object.
extension type OpenAPIComponents._(Map<String, Object?> _) {
  /// Creates an OpenAPI components object.
  factory OpenAPIComponents({
    Map<String, Object?>? schemas,
    Map<String, Object?>? responses,
    Map<String, Object?>? parameters,
    Map<String, Object?>? examples,
    Map<String, Object?>? requestBodies,
    Map<String, Object?>? headers,
    Map<String, Object?>? securitySchemes,
    Map<String, Object?>? links,
    Map<String, Object?>? callbacks,
    Map<String, Object?>? pathItems,
  }) => OpenAPIComponents._({
    ...?switch (schemas) {
      final value? => {'schemas': value},
      null => null,
    },
    ...?switch (responses) {
      final value? => {'responses': value},
      null => null,
    },
    ...?switch (parameters) {
      final value? => {'parameters': value},
      null => null,
    },
    ...?switch (examples) {
      final value? => {'examples': value},
      null => null,
    },
    ...?switch (requestBodies) {
      final value? => {'requestBodies': value},
      null => null,
    },
    ...?switch (headers) {
      final value? => {'headers': value},
      null => null,
    },
    ...?switch (securitySchemes) {
      final value? => {'securitySchemes': value},
      null => null,
    },
    ...?switch (links) {
      final value? => {'links': value},
      null => null,
    },
    ...?switch (callbacks) {
      final value? => {'callbacks': value},
      null => null,
    },
    ...?switch (pathItems) {
      final value? => {'pathItems': value},
      null => null,
    },
  });
}

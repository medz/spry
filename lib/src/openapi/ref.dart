/// OpenAPI `reference-or-inline` wrapper.
extension type OpenAPIRef<T>._(Object? _) {
  /// Returns an inline value without wrapping.
  factory OpenAPIRef.inline(T value) => OpenAPIRef._(value as Object?);

  /// Creates a `$ref` object.
  factory OpenAPIRef.ref(String $ref, {String? summary, String? description}) =>
      OpenAPIRef._({
        r'$ref': $ref,
        ...?switch (summary) {
          final value? => {'summary': value},
          null => null,
        },
        ...?switch (description) {
          final value? => {'description': value},
          null => null,
        },
      });
}

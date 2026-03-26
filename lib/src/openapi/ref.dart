/// OpenAPI `reference-or-inline` wrapper.
extension type OpenAPIRef<T>._(Object? _) {
  /// Returns an inline value without wrapping.
  factory OpenAPIRef.inline(T value) => OpenAPIRef._(value);

  /// Creates a `$ref` object.
  factory OpenAPIRef.ref(String $ref, {String? summary, String? description}) =>
      OpenAPIRef._({
        r'$ref': $ref,
        'summary': ?summary,
        'description': ?description,
      });
}

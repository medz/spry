// ignore_for_file: non_constant_identifier_names

Map<String, Object?> OpenAPI({String? summary, Object? globalComponents}) => {
  'summary': ?summary,
  'x-spry-openapi-global-components': ?globalComponents,
};

Map<String, Object?> OpenAPIComponents({Map<String, Object?>? schemas}) => {
  'schemas': ?schemas,
};

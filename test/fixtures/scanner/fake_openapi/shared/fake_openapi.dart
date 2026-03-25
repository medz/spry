// ignore_for_file: non_constant_identifier_names, use_null_aware_elements

Map<String, Object?> OpenAPI({String? summary, Object? globalComponents}) => {
  if (summary != null) 'summary': summary,
  if (globalComponents != null)
    'x-spry-openapi-global-components': globalComponents,
};

Map<String, Object?> OpenAPIComponents({Map<String, Object?>? schemas}) => {
  if (schemas != null) 'schemas': schemas,
};

import '_openapi_utils.dart';
import 'media_type.dart';

/// OpenAPI `request-body` object.
extension type OpenAPIRequestBody._(Map<String, Object?> _) {
  /// Creates a request body object.
  factory OpenAPIRequestBody({
    required Map<String, OpenAPIMediaType> content,
    String? description,
    bool? required,
    Map<String, dynamic>? extensions,
  }) => OpenAPIRequestBody._({
    'content': content,
    'description': ?description,
    'required': ?required,
    ...?prefixExtensions(extensions),
  });
}

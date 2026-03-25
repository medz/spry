import '_openapi_utils.dart';
import 'header.dart';
import 'link.dart';
import 'media_type.dart';
import 'ref.dart';

/// OpenAPI `response` object.
extension type OpenAPIResponse._(Map<String, Object?> _) {
  /// Creates a response object.
  factory OpenAPIResponse({
    required String description,
    Map<String, OpenAPIRef<OpenAPIHeader>>? headers,
    Map<String, OpenAPIMediaType>? content,
    Map<String, OpenAPIRef<OpenAPILink>>? links,
    Map<String, dynamic>? extensions,
  }) => OpenAPIResponse._({
    'description': description,
    'headers': ?headers,
    'content': ?content,
    'links': ?links,
    ...?prefixExtensions(extensions),
  });
}

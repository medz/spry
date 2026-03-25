import '_openapi_utils.dart';
import 'components.dart';
import 'info.dart';
import 'path_item.dart';
import 'security.dart';
import 'server.dart';
import 'tag.dart';

/// Generated OpenAPI root document.
extension type OpenAPIDocument._(Map<String, Object?> _) {
  /// Creates a full OpenAPI 3.1 document.
  factory OpenAPIDocument({
    required OpenAPIInfo info,
    required Map<String, OpenAPIPathItem> paths,
    OpenAPIComponents? components,
    List<OpenAPIServer>? servers,
    Map<String, OpenAPIPathItem>? webhooks,
    List<OpenAPISecurityRequirement>? security,
    List<OpenAPITag>? tags,
    OpenAPIExternalDocs? externalDocs,
    String? jsonSchemaDialect,
    Map<String, dynamic>? extensions,
  }) => OpenAPIDocument._({
    'openapi': '3.1.0',
    'info': info,
    'paths': paths,
    'components': ?components,
    'servers': ?servers,
    'webhooks': ?webhooks,
    'security': ?security,
    'tags': ?tags,
    'externalDocs': ?externalDocs,
    'jsonSchemaDialect': ?jsonSchemaDialect,
    ...?prefixExtensions(extensions),
  });
}

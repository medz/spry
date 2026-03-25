import 'components.dart';
import 'info.dart';
import 'path_item.dart';
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
    List<Object?>? security,
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
    ...?_prefixExtensions(extensions),
  });
}

Map<String, Object?>? _prefixExtensions(Map<String, dynamic>? extensions) {
  if (extensions == null) {
    return null;
  }
  return {
    for (final entry in extensions.entries) 'x-${entry.key}': entry.value,
  };
}

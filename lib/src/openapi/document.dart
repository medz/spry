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
    ...?switch (components) {
      final value? => {'components': value},
      null => null,
    },
    ...?switch (servers) {
      final value? => {'servers': value},
      null => null,
    },
    ...?switch (webhooks) {
      final value? => {'webhooks': value},
      null => null,
    },
    ...?switch (security) {
      final value? => {'security': value},
      null => null,
    },
    ...?switch (tags) {
      final value? => {'tags': value},
      null => null,
    },
    ...?switch (externalDocs) {
      final value? => {'externalDocs': value},
      null => null,
    },
    ...?switch (jsonSchemaDialect) {
      final value? => {'jsonSchemaDialect': value},
      null => null,
    },
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

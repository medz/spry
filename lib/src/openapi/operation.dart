import 'components.dart';

/// Minimal route-side OpenAPI operation object.
extension type OpenAPI._(Map<String, Object?> _) {
  /// Creates an OpenAPI operation object for route metadata.
  factory OpenAPI({
    List<String>? tags,
    String? summary,
    String? description,
    Object? externalDocs,
    String? operationId,
    Object? parameters,
    Object? requestBody,
    Object? responses,
    Object? callbacks,
    bool? deprecated,
    Object? security,
    Object? servers,
    Map<String, dynamic>? extensions,
    OpenAPIComponents? globalComponents,
  }) => OpenAPI._({
    ...?switch (tags) {
      final value? => {'tags': value},
      null => null,
    },
    ...?switch (summary) {
      final value? => {'summary': value},
      null => null,
    },
    ...?switch (description) {
      final value? => {'description': value},
      null => null,
    },
    ...?switch (externalDocs) {
      final value? => {'externalDocs': value},
      null => null,
    },
    ...?switch (operationId) {
      final value? => {'operationId': value},
      null => null,
    },
    ...?switch (parameters) {
      final value? => {'parameters': value},
      null => null,
    },
    ...?switch (requestBody) {
      final value? => {'requestBody': value},
      null => null,
    },
    ...?switch (responses) {
      final value? => {'responses': value},
      null => null,
    },
    ...?switch (callbacks) {
      final value? => {'callbacks': value},
      null => null,
    },
    ...?switch (deprecated) {
      final value? => {'deprecated': value},
      null => null,
    },
    ...?switch (security) {
      final value? => {'security': value},
      null => null,
    },
    ...?switch (servers) {
      final value? => {'servers': value},
      null => null,
    },
    ...?_prefixExtensions(extensions),
    ...?switch (globalComponents) {
      final value? => {'x-spry-openapi-global-components': value},
      null => null,
    },
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

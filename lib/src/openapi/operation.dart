import 'components.dart';
import 'server.dart';
import 'tag.dart';

/// Route-level OpenAPI metadata object.
extension type OpenAPI._(Map<String, Object?> _) {
  /// Creates route metadata and allows extra route-level global components.
  factory OpenAPI({
    List<String>? tags,
    String? summary,
    String? description,
    OpenAPIExternalDocs? externalDocs,
    String? operationId,
    Object? parameters,
    Object? requestBody,
    Object? responses,
    Object? callbacks,
    bool? deprecated,
    Object? security,
    List<OpenAPIServer>? servers,
    Map<String, dynamic>? extensions,
    OpenAPIComponents? globalComponents,
  }) => OpenAPI._({
    ..._buildOperationMap(
      tags: tags,
      summary: summary,
      description: description,
      externalDocs: externalDocs,
      operationId: operationId,
      parameters: parameters,
      requestBody: requestBody,
      responses: responses,
      callbacks: callbacks,
      deprecated: deprecated,
      security: security,
      servers: servers,
      extensions: extensions,
    ),
    ...?switch (globalComponents) {
      final value? => {'x-spry-openapi-global-components': value},
      null => null,
    },
  });
}

/// OpenAPI 3.1 operation object.
extension type OpenAPIOperation._(Map<String, Object?> _) {
  /// Creates an OpenAPI operation object.
  factory OpenAPIOperation({
    List<String>? tags,
    String? summary,
    String? description,
    OpenAPIExternalDocs? externalDocs,
    String? operationId,
    Object? parameters,
    Object? requestBody,
    Object? responses,
    Object? callbacks,
    bool? deprecated,
    Object? security,
    List<OpenAPIServer>? servers,
    Map<String, dynamic>? extensions,
  }) => OpenAPIOperation._(
    _buildOperationMap(
      tags: tags,
      summary: summary,
      description: description,
      externalDocs: externalDocs,
      operationId: operationId,
      parameters: parameters,
      requestBody: requestBody,
      responses: responses,
      callbacks: callbacks,
      deprecated: deprecated,
      security: security,
      servers: servers,
      extensions: extensions,
    ),
  );

  /// Wraps decoded JSON.
  factory OpenAPIOperation.fromJson(Map<String, dynamic> json) =>
      OpenAPIOperation._(json.cast<String, Object?>());
}

Map<String, Object?> _buildOperationMap({
  List<String>? tags,
  String? summary,
  String? description,
  OpenAPIExternalDocs? externalDocs,
  String? operationId,
  Object? parameters,
  Object? requestBody,
  Object? responses,
  Object? callbacks,
  bool? deprecated,
  Object? security,
  List<OpenAPIServer>? servers,
  Map<String, dynamic>? extensions,
}) => {
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
};

Map<String, Object?>? _prefixExtensions(Map<String, dynamic>? extensions) {
  if (extensions == null) {
    return null;
  }
  return {
    for (final entry in extensions.entries) 'x-${entry.key}': entry.value,
  };
}

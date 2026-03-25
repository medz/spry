import 'server.dart';

/// OpenAPI `link` object.
extension type OpenAPILink._(Map<String, Object?> _) {
  /// Creates a link object.
  factory OpenAPILink({
    String? operationRef,
    String? operationId,
    Map<String, String>? parameters,
    Object? requestBody,
    String? description,
    OpenAPIServer? server,
    Map<String, dynamic>? extensions,
  }) {
    _validateLinkOperationFields(
      operationRef: operationRef,
      operationId: operationId,
      scope: 'OpenAPILink',
    );
    return OpenAPILink._({
      'operationRef': ?operationRef,
      'operationId': ?operationId,
      'parameters': ?parameters,
      'requestBody': ?requestBody,
      'description': ?description,
      'server': ?server,
      ...?_prefixExtensions(extensions),
    });
  }
}

void _validateLinkOperationFields({
  required String? operationRef,
  required String? operationId,
  required String scope,
}) {
  if (operationRef != null && operationId != null) {
    throw ArgumentError(
      '$scope.operationRef and $scope.operationId are mutually exclusive.',
    );
  }
}

Map<String, Object?>? _prefixExtensions(Map<String, dynamic>? extensions) {
  if (extensions == null) {
    return null;
  }
  return {
    for (final entry in extensions.entries) 'x-${entry.key}': entry.value,
  };
}

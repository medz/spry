import '_openapi_utils.dart';
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
    Map<String, Object?>? extensions,
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
      ...?prefixExtensions(extensions),
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
  if (operationRef == null && operationId == null) {
    throw ArgumentError(
      '$scope must specify exactly one of operationRef or operationId.',
    );
  }
}

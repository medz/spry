import '_openapi_utils.dart';
import 'callback.dart';
import 'components.dart';
import 'parameter.dart';
import 'ref.dart';
import 'request_body.dart';
import 'response.dart';
import 'security.dart';
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
    List<OpenAPIRef<OpenAPIParameter>>? parameters,
    OpenAPIRef<OpenAPIRequestBody>? requestBody,
    Map<String, OpenAPIRef<OpenAPIResponse>>? responses,
    Map<String, OpenAPIRef<OpenAPICallback>>? callbacks,
    bool? deprecated,
    List<OpenAPISecurityRequirement>? security,
    List<OpenAPIServer>? servers,
    Map<String, Object?>? extensions,
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
    'x-spry-openapi-global-components': ?globalComponents,
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
    List<OpenAPIRef<OpenAPIParameter>>? parameters,
    OpenAPIRef<OpenAPIRequestBody>? requestBody,
    Map<String, OpenAPIRef<OpenAPIResponse>>? responses,
    Map<String, OpenAPIRef<OpenAPICallback>>? callbacks,
    bool? deprecated,
    List<OpenAPISecurityRequirement>? security,
    List<OpenAPIServer>? servers,
    Map<String, Object?>? extensions,
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
  factory OpenAPIOperation.fromJson(Map<String, Object?> json) =>
      OpenAPIOperation._(Map<String, Object?>.from(json));
}

Map<String, Object?> _buildOperationMap({
  List<String>? tags,
  String? summary,
  String? description,
  OpenAPIExternalDocs? externalDocs,
  String? operationId,
  List<OpenAPIRef<OpenAPIParameter>>? parameters,
  OpenAPIRef<OpenAPIRequestBody>? requestBody,
  Map<String, OpenAPIRef<OpenAPIResponse>>? responses,
  Map<String, OpenAPIRef<OpenAPICallback>>? callbacks,
  bool? deprecated,
  List<OpenAPISecurityRequirement>? security,
  List<OpenAPIServer>? servers,
  Map<String, Object?>? extensions,
}) => {
  'tags': ?tags,
  'summary': ?summary,
  'description': ?description,
  'externalDocs': ?externalDocs,
  'operationId': ?operationId,
  'parameters': ?parameters,
  'requestBody': ?requestBody,
  'responses': ?responses,
  'callbacks': ?callbacks,
  'deprecated': ?deprecated,
  'security': ?security,
  'servers': ?servers,
  ...?prefixExtensions(extensions),
};

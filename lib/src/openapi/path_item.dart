import '_openapi_utils.dart';
import 'operation.dart';
import 'parameter.dart';
import 'ref.dart';
import 'server.dart';

/// OpenAPI `path-item` object.
extension type OpenAPIPathItem._(Map<String, Object?> _) {
  /// Creates a path item object.
  factory OpenAPIPathItem({
    String? $ref,
    String? summary,
    String? description,
    List<OpenAPIServer>? servers,
    List<OpenAPIRef<OpenAPIParameter>>? parameters,
    OpenAPIOperation? get,
    OpenAPIOperation? put,
    OpenAPIOperation? post,
    OpenAPIOperation? delete,
    OpenAPIOperation? options,
    OpenAPIOperation? head,
    OpenAPIOperation? patch,
    OpenAPIOperation? trace,
    Map<String, Object?>? extensions,
  }) => OpenAPIPathItem._({
    r'$ref': ?$ref,
    'summary': ?summary,
    'description': ?description,
    'servers': ?servers,
    'parameters': ?parameters,
    'get': ?get,
    'put': ?put,
    'post': ?post,
    'delete': ?delete,
    'options': ?options,
    'head': ?head,
    'patch': ?patch,
    'trace': ?trace,
    ...?prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIPathItem.fromJson(Map<String, Object?> json) =>
      OpenAPIPathItem._({
        r'$ref': ?_optionalString(json, r'$ref'),
        'summary': ?_optionalString(json, 'summary'),
        'description': ?_optionalString(json, 'description'),
        if (json.containsKey('servers'))
          'servers': _requireList(json['servers'], 'servers')
              .map((entry) => OpenAPIServer.fromJson(_requireMap(entry)))
              .toList(),
        if (json.containsKey('parameters'))
          'parameters': _requireList(json['parameters'], 'parameters'),
        'get': ?_operation(json, 'get'),
        'put': ?_operation(json, 'put'),
        'post': ?_operation(json, 'post'),
        'delete': ?_operation(json, 'delete'),
        'options': ?_operation(json, 'options'),
        'head': ?_operation(json, 'head'),
        'patch': ?_operation(json, 'patch'),
        'trace': ?_operation(json, 'trace'),
        ...extractExtensions(json),
      });
}

OpenAPIOperation? _operation(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) return null;
  final value = json[key];
  if (value == null) return null;
  if (value is Map<String, Object?>) return OpenAPIOperation.fromJson(value);
  throw FormatException(
    'Invalid openapi path item.$key: expected a JSON object.',
  );
}

Map<String, Object?> _requireMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  throw FormatException(
    'Invalid openapi path item value: expected a JSON object.',
  );
}

List<Object?> _requireList(Object? value, String key) {
  if (value is List) return value.cast<Object?>();
  throw FormatException(
    'Invalid openapi path item.$key: expected a JSON array.',
  );
}

String? _optionalString(Map<String, Object?> json, String key) {
  if (!json.containsKey(key)) return null;
  final value = json[key];
  if (value == null || value is String) return value as String?;
  throw FormatException(
    'Invalid openapi path item.$key: expected a string, got ${value.runtimeType}.',
  );
}

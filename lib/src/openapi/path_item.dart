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
        r'$ref': ?optionalString(json, r'$ref', scope: 'openapi path item'),
        'summary': ?optionalString(json, 'summary', scope: 'openapi path item'),
        'description': ?optionalString(
          json,
          'description',
          scope: 'openapi path item',
        ),
        if (json.containsKey('servers'))
          'servers':
              requireList(json['servers'], scope: 'openapi path item.servers')
                  .map(
                    (entry) => OpenAPIServer.fromJson(
                      requireMap(entry, scope: 'openapi path item'),
                    ),
                  )
                  .toList(),
        if (json.containsKey('parameters'))
          'parameters': _decodeParameters(json['parameters']),
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

List<Map<String, Object?>> _decodeParameters(Object? value) {
  final parameters = requireList(value, scope: 'openapi path item.parameters');
  return [
    for (var i = 0; i < parameters.length; i++)
      requireMap(parameters[i], scope: 'openapi path item.parameters[$i]'),
  ];
}

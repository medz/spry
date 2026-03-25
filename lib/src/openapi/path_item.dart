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
    Map<String, dynamic>? extensions,
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
    ...?_prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIPathItem.fromJson(Map<String, dynamic> json) =>
      OpenAPIPathItem._({
        r'$ref': ?_string(json[r'$ref']),
        'summary': ?_string(json['summary']),
        'description': ?_string(json['description']),
        if (json['servers'] case final List value)
          'servers': value
              .cast<Object?>()
              .map((entry) => OpenAPIServer.fromJson(_requireMap(entry)))
              .toList(),
        if (json['parameters'] case final List value)
          'parameters': value.cast<Object?>(),
        'get': ?_operation(json, 'get'),
        'put': ?_operation(json, 'put'),
        'post': ?_operation(json, 'post'),
        'delete': ?_operation(json, 'delete'),
        'options': ?_operation(json, 'options'),
        'head': ?_operation(json, 'head'),
        'patch': ?_operation(json, 'patch'),
        'trace': ?_operation(json, 'trace'),
        ..._extractExtensions(json),
      });
}

OpenAPIOperation? _operation(Map<String, dynamic> json, String key) {
  if (json[key] case final Map<String, dynamic> value) {
    return OpenAPIOperation.fromJson(value);
  }
  return null;
}

Map<String, dynamic> _requireMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  throw FormatException(
    'Invalid openapi path item value: expected a JSON object.',
  );
}

Map<String, Object?> _extractExtensions(Map<String, dynamic> json) {
  return {
    for (final entry in json.entries)
      if (entry.key.startsWith('x-')) entry.key: entry.value,
  };
}

Map<String, Object?>? _prefixExtensions(Map<String, dynamic>? extensions) {
  if (extensions == null) {
    return null;
  }
  return {
    for (final entry in extensions.entries) 'x-${entry.key}': entry.value,
  };
}

String? _string(Object? value) => value is String ? value : null;

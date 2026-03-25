import 'callback.dart';
import 'example.dart';
import 'header.dart';
import 'link.dart';
import 'path_item.dart';
import 'parameter.dart';
import 'ref.dart';
import 'request_body.dart';
import 'response.dart';
import 'schema.dart';
import 'security.dart';

/// OpenAPI components object.
extension type OpenAPIComponents._(Map<String, Object?> _) {
  /// Creates an OpenAPI components object.
  factory OpenAPIComponents({
    Map<String, OpenAPISchema>? schemas,
    Map<String, OpenAPIRef<OpenAPIResponse>>? responses,
    Map<String, OpenAPIRef<OpenAPIParameter>>? parameters,
    Map<String, OpenAPIRef<OpenAPIExample>>? examples,
    Map<String, OpenAPIRef<OpenAPIRequestBody>>? requestBodies,
    Map<String, OpenAPIRef<OpenAPIHeader>>? headers,
    Map<String, OpenAPIRef<OpenAPISecurityScheme>>? securitySchemes,
    Map<String, OpenAPIRef<OpenAPILink>>? links,
    Map<String, OpenAPIRef<OpenAPICallback>>? callbacks,
    Map<String, OpenAPIPathItem>? pathItems,
    Map<String, dynamic>? extensions,
  }) => OpenAPIComponents._({
    'schemas': ?schemas,
    'responses': ?responses,
    'parameters': ?parameters,
    'examples': ?examples,
    'requestBodies': ?requestBodies,
    'headers': ?headers,
    'securitySchemes': ?securitySchemes,
    'links': ?links,
    'callbacks': ?callbacks,
    'pathItems': ?pathItems,
    ...?_prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIComponents.fromJson(Map<String, dynamic> json) =>
      OpenAPIComponents._({
        if (json['schemas'] case final Map<String, dynamic> value)
          'schemas': value.cast<String, Object?>(),
        if (json['responses'] case final Map<String, dynamic> value)
          'responses': value.cast<String, Object?>(),
        if (json['parameters'] case final Map<String, dynamic> value)
          'parameters': value.cast<String, Object?>(),
        if (json['examples'] case final Map<String, dynamic> value)
          'examples': value.cast<String, Object?>(),
        if (json['requestBodies'] case final Map<String, dynamic> value)
          'requestBodies': value.cast<String, Object?>(),
        if (json['headers'] case final Map<String, dynamic> value)
          'headers': value.cast<String, Object?>(),
        if (json['securitySchemes'] case final Map<String, dynamic> value)
          'securitySchemes': value.cast<String, Object?>(),
        if (json['links'] case final Map<String, dynamic> value)
          'links': value.cast<String, Object?>(),
        if (json['callbacks'] case final Map<String, dynamic> value)
          'callbacks': value.cast<String, Object?>(),
        if (json['pathItems'] case final Map<String, dynamic> value)
          'pathItems': {
            for (final entry in value.entries)
              entry.key: OpenAPIPathItem.fromJson(_requireMap(entry.value)),
          },
        ..._extractExtensions(json),
      });
}

Map<String, dynamic> _requireMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  throw FormatException(
    'Invalid openapi.components value: expected a JSON object.',
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

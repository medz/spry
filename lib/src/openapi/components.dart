import '_openapi_utils.dart';
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
    Map<String, Object?>? extensions,
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
    ...?prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIComponents.fromJson(Map<String, Object?> json) =>
      OpenAPIComponents._({
        if (json['schemas'] case final Map<String, Object?> value)
          'schemas': value.cast<String, Object?>(),
        if (json['responses'] case final Map<String, Object?> value)
          'responses': value.cast<String, Object?>(),
        if (json['parameters'] case final Map<String, Object?> value)
          'parameters': value.cast<String, Object?>(),
        if (json['examples'] case final Map<String, Object?> value)
          'examples': value.cast<String, Object?>(),
        if (json['requestBodies'] case final Map<String, Object?> value)
          'requestBodies': value.cast<String, Object?>(),
        if (json['headers'] case final Map<String, Object?> value)
          'headers': value.cast<String, Object?>(),
        if (json['securitySchemes'] case final Map<String, Object?> value)
          'securitySchemes': value.cast<String, Object?>(),
        if (json['links'] case final Map<String, Object?> value)
          'links': value.cast<String, Object?>(),
        if (json['callbacks'] case final Map<String, Object?> value)
          'callbacks': value.cast<String, Object?>(),
        if (json['pathItems'] case final Map<String, Object?> value)
          'pathItems': {
            for (final entry in value.entries)
              entry.key: OpenAPIPathItem.fromJson(_requireMap(entry.value)),
          },
        ...extractExtensions(json),
      });
}

Map<String, Object?> _requireMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  throw FormatException(
    'Invalid openapi.components value: expected a JSON object.',
  );
}

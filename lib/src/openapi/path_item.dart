import 'operation.dart';
import 'server.dart';

/// OpenAPI `path-item` object.
extension type OpenAPIPathItem._(Map<String, Object?> _) {
  /// Creates a path item object.
  factory OpenAPIPathItem({
    String? $ref,
    String? summary,
    String? description,
    List<OpenAPIServer>? servers,
    List<Object?>? parameters,
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
    ...?switch ($ref) {
      final value? => {r'$ref': value},
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
    ...?switch (servers) {
      final value? => {'servers': value},
      null => null,
    },
    ...?switch (parameters) {
      final value? => {'parameters': value},
      null => null,
    },
    ...?switch (get) {
      final value? => {'get': value},
      null => null,
    },
    ...?switch (put) {
      final value? => {'put': value},
      null => null,
    },
    ...?switch (post) {
      final value? => {'post': value},
      null => null,
    },
    ...?switch (delete) {
      final value? => {'delete': value},
      null => null,
    },
    ...?switch (options) {
      final value? => {'options': value},
      null => null,
    },
    ...?switch (head) {
      final value? => {'head': value},
      null => null,
    },
    ...?switch (patch) {
      final value? => {'patch': value},
      null => null,
    },
    ...?switch (trace) {
      final value? => {'trace': value},
      null => null,
    },
    ...?_prefixExtensions(extensions),
  });

  /// Wraps decoded JSON.
  factory OpenAPIPathItem.fromJson(Map<String, dynamic> json) =>
      OpenAPIPathItem._({
        ...?switch (_string(json[r'$ref'])) {
          final value? => {r'$ref': value},
          null => null,
        },
        ...?switch (_string(json['summary'])) {
          final value? => {'summary': value},
          null => null,
        },
        ...?switch (_string(json['description'])) {
          final value? => {'description': value},
          null => null,
        },
        if (json['servers'] case final List value)
          'servers': value
              .cast<Object?>()
              .map((entry) => OpenAPIServer.fromJson(_requireMap(entry)))
              .toList(),
        if (json['parameters'] case final List value)
          'parameters': value.cast<Object?>(),
        ...?switch (_operation(json, 'get')) {
          final value? => {'get': value},
          null => null,
        },
        ...?switch (_operation(json, 'put')) {
          final value? => {'put': value},
          null => null,
        },
        ...?switch (_operation(json, 'post')) {
          final value? => {'post': value},
          null => null,
        },
        ...?switch (_operation(json, 'delete')) {
          final value? => {'delete': value},
          null => null,
        },
        ...?switch (_operation(json, 'options')) {
          final value? => {'options': value},
          null => null,
        },
        ...?switch (_operation(json, 'head')) {
          final value? => {'head': value},
          null => null,
        },
        ...?switch (_operation(json, 'patch')) {
          final value? => {'patch': value},
          null => null,
        },
        ...?switch (_operation(json, 'trace')) {
          final value? => {'trace': value},
          null => null,
        },
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

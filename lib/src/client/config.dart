import 'package:ht/ht.dart' show Headers;

/// Global client generation settings for `spry.config.dart`.
extension type ClientConfig._(Map<String, Object?> _) {
  /// Creates a client config object.
  factory ClientConfig({
    required String output,
    String? endpoint,
    String? pubspec,
    Headers? headers,
  }) => ClientConfig._({
    'output': output,
    'endpoint': ?endpoint,
    'pubspec': ?pubspec,
    'headers': ?_encodeHeaders(headers),
  });

  /// Wraps decoded JSON.
  factory ClientConfig.fromJson(Map<String, Object?> json) => ClientConfig._({
    'output': _requireString(json, 'output', scope: 'client'),
    'endpoint': ?_optionalString(json, 'endpoint', scope: 'client'),
    'pubspec': ?_optionalStringField(json['pubspec'], scope: 'client.pubspec'),
    'headers': ?_optionalHeaders(json['headers'], scope: 'client.headers'),
  });

  /// Output directory relative to the project root.
  String get output => _['output'] as String;

  /// Optional default endpoint for generated clients.
  String? get endpoint => _['endpoint'] as String?;

  /// Optional template pubspec path for generated client artifacts.
  String? get pubspec => _['pubspec'] as String?;

  /// Optional static global headers for generated clients.
  Headers? get headers => switch (_['headers']) {
    null => null,
    final headers => Headers(headers),
  };
}

Map<String, List<String>>? _encodeHeaders(Headers? headers) {
  if (headers == null) {
    return null;
  }

  final encoded = <String, List<String>>{};
  for (final MapEntry(:key, :value) in headers.entries()) {
    (encoded[key] ??= <String>[]).add(value);
  }
  return encoded;
}

String? _optionalString(
  Map<String, Object?> json,
  String key, {
  required String scope,
}) {
  if (!json.containsKey(key)) {
    return null;
  }

  final value = json[key];
  if (value == null || value is String) {
    return value as String?;
  }

  throw FormatException(
    'Invalid $scope.$key: expected a string, got ${value.runtimeType}.',
  );
}

String? _optionalStringField(Object? value, {required String scope}) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }

  throw FormatException(
    'Invalid $scope: expected a string, got ${value.runtimeType}.',
  );
}

String _requireString(
  Map<String, Object?> json,
  String key, {
  required String scope,
}) {
  final value = json[key];
  if (value is String) {
    return value;
  }

  throw FormatException('Invalid $scope.$key: expected a string.');
}

Map<String, List<String>>? _optionalHeaders(
  Object? value, {
  required String scope,
}) {
  if (value == null) {
    return null;
  }
  if (value is! Map) {
    throw FormatException('Invalid $scope: expected a JSON object.');
  }

  final headers = <String, List<String>>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String) {
      throw FormatException('Invalid $scope: expected string header names.');
    }

    final normalized = switch (entry.value) {
      String() => <String>[entry.value],
      List() => _requireStringList(entry.value, scope: '$scope.$key'),
      _ => throw FormatException(
        'Invalid $scope.$key: expected a string or string array.',
      ),
    };

    headers[key] = normalized;
  }

  return headers;
}

List<String> _requireStringList(Object? value, {required String scope}) {
  if (value is! List) {
    throw FormatException('Invalid $scope: expected a string array.');
  }

  final result = <String>[];
  for (final entry in value) {
    if (entry is! String) {
      throw FormatException('Invalid $scope: expected a string array.');
    }
    result.add(entry);
  }
  return result;
}

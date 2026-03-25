/// OpenAPI `info` object used by config and document models.
extension type OpenAPIInfo._(Map<String, Object?> _) {
  /// Creates an OpenAPI info object.
  factory OpenAPIInfo({
    required String title,
    required String version,
    String? summary,
    String? description,
  }) => OpenAPIInfo._({
    'title': title,
    'version': version,
    ...?switch (summary) {
      final value? => {'summary': value},
      null => null,
    },
    ...?switch (description) {
      final value? => {'description': value},
      null => null,
    },
  });

  /// Wraps decoded JSON.
  factory OpenAPIInfo.fromJson(Map<String, dynamic> json) => OpenAPIInfo._({
    'title': _requireString(json, 'title'),
    'version': _requireString(json, 'version'),
    ...?switch (_string(json['summary'])) {
      final value? => {'summary': value},
      null => null,
    },
    ...?switch (_string(json['description'])) {
      final value? => {'description': value},
      null => null,
    },
  });

  /// API title.
  String get title => _['title'] as String;

  /// API version.
  String get version => _['version'] as String;

  /// Optional summary.
  String? get summary => _['summary'] as String?;

  /// Optional description.
  String? get description => _['description'] as String?;
}

String _requireString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }
  throw FormatException('Invalid openapi.$key: expected a string.');
}

String? _string(Object? value) => value is String ? value : null;

/// MCP server configuration for `spry.config.dart`.
extension type McpConfig._(Map<String, Object?> _) {
  /// Creates an MCP configuration.
  ///
  /// When [enable] is `true`, `spry serve` starts an MCP HTTP endpoint
  /// alongside the dev server so AI agents can inspect the project.
  factory McpConfig({
    bool enable = false,
    int? port,
  }) => McpConfig._({
    'enable': enable,
    'port': ?port,
  });

  /// Wraps decoded JSON.
  factory McpConfig.fromJson(Map<String, Object?> json) => McpConfig._({
    'enable': _optionalBool(json['enable']) ?? false,
    'port': ?_optionalInt(json['port']),
  });

  /// Whether the MCP server is enabled.
  bool get enable => _['enable'] as bool;

  /// Optional MCP HTTP port override. Defaults to the app port + 1.
  int? get port => _['port'] as int?;

  /// Effective MCP port — [port] if set, otherwise [defaultPort].
  int effectivePort(int defaultPort) => port ?? defaultPort + 1;
}

bool? _optionalBool(Object? value) => switch (value) {
  null => null,
  bool() => value,
  _ => throw FormatException('expected a bool, got ${value.runtimeType}'),
};

int? _optionalInt(Object? value) => switch (value) {
  null => null,
  int() => value,
  num() when value == value.roundToDouble() => value.toInt(),
  String() => int.tryParse(value),
  _ => throw FormatException('expected an int, got ${value.runtimeType}'),
};

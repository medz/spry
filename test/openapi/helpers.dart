import 'dart:convert';

/// Round-trips [value] through JSON encode/decode to produce a plain Dart
/// object (Map/List/String/num/bool/null) suitable for use in `expect` calls.
dynamic decodeJsonValue(dynamic value) => jsonDecode(jsonEncode(value));

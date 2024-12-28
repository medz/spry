String normalizeHeaderName(String name) => name.trim().toLowerCase();

String? getHeaderSubParam(String? contentType, String name) {
  if (contentType == null || contentType.isEmpty) {
    return null;
  }

  final normalizedName = normalizeHeaderName(name);
  for (final part in contentType.split(';')) {
    final [name, ...values] = part.trim().split('=');
    if (normalizeHeaderName(name) == normalizedName) {
      return values.join('=').trim().escaped;
    }
  }

  return null;
}

T tryRun<T>(T Function(T) fn, T value) {
  try {
    return fn(value);
  } catch (_) {
    return value;
  }
}

extension on String {
  /// Returns the string ' and " escaped for start and end.
  String get escaped {
    if (startsWith('"') || startsWith("'")) return substring(1).escaped;
    if (endsWith('"') || endsWith("'")) return substring(0, length - 1).escaped;
    return this;
  }
}

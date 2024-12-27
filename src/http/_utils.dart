import 'dart:convert';

String normalizeHeaderName(String name) => name.trim().toLowerCase();

Encoding getContentTypeCharset(String? contentType) {
  if (contentType == null || contentType.isEmpty) {
    return utf8;
  }

  for (String part in contentType.split(';')) {
    final [name, ...values] = part.trim().split('=');
    final key = normalizeHeaderName(name);
    if (key == 'charset') {
      final name = normalizeHeaderName(values.join('='));
      final encoding = Encoding.getByName(name);
      if (encoding != null) return encoding;
    }
  }

  return utf8;
}

T tryRun<T>(T Function(T) fn, T value) {
  try {
    return fn(value);
  } catch (_) {
    return value;
  }
}

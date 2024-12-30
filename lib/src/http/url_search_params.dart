import '_utils.dart';

/// URL search params.
extension type URLSearchParams._(List<(String, String)> _params)
    implements Iterable<(String, String)> {
  /// Creates a new [URLSearchParams] instance.
  factory URLSearchParams([Map<String, String>? init]) {
    final params = URLSearchParams._([]);
    if (init != null && init.isNotEmpty) {
      for (final MapEntry(:key, :value) in init.entries) {
        params.add(key, value);
      }
    }

    return params;
  }

  /// Parse a query string to [URLSearchParams].
  factory URLSearchParams.parse(String query) {
    final queryWithoutAnchor = query.split('#').first.trim();
    final queryWithoutMark = queryWithoutAnchor.startsWith('?')
        ? queryWithoutAnchor.substring(1)
        : queryWithoutAnchor;
    final params = URLSearchParams();
    for (final part in queryWithoutMark.trim().split('&')) {
      final [name, ...values] = part.split('=');
      final value = values.join('=').trim();
      params.add(normalizeHeaderName(name), value);
    }

    return params;
  }

  /// Returns the query first value from [name].
  String? get(String name) {
    final normalizedName = normalizeHeaderName(name);
    for (final (name, value) in this) {
      if (normalizedName == name) return value;
    }

    return null;
  }

  /// Returns all query values from [name].
  Iterable<String> getAll(String name) sync* {
    final normalizedName = normalizeHeaderName(name);
    for (final (name, value) in this) {
      if (normalizedName == name) yield value;
    }
  }

  /// Adds a new query param.
  void add(String name, String value) {
    _params.add((
      normalizeHeaderName(name),
      tryRun(Uri.decodeQueryComponent, value),
    ));
  }

  /// Sets a query key-value part.
  ///
  /// if the [name] exists, remove it.
  void set(String name, String value) {
    final normalizedName = normalizeHeaderName(name);
    _params
      ..removeWhere((e) => e.$1 == normalizedName)
      ..add((
        normalizedName,
        tryRun(Uri.decodeQueryComponent, value),
      ));
  }

  /// Remove a param.
  void remove(String name, [String? value]) {
    final normalizedName = normalizeHeaderName(name);
    bool test((String, String) e) {
      if (value != null) {
        return e.$1 == normalizedName && e.$2 == value;
      }

      return e.$1 == normalizedName;
    }

    _params.removeWhere(test);
  }

  /// Serialize to query string.
  String toQueryString() {
    final params = <String, List<String>>{};
    for (final (name, value) in this) {
      final values = params[name] ?? [];
      values.add(tryRun(Uri.encodeQueryComponent, value));
    }

    return Uri(queryParameters: params).query;
  }
}

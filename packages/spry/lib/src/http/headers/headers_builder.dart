import 'headers.dart';

/// [Headers] builder.
abstract interface class HeadersBuilder {
  /// Creates a new [HeadersBuilder].
  factory HeadersBuilder([Iterable<(String, String)>? init]) {
    final builder = _HeadersBuilderImpl();

    if (init != null && init.isNotEmpty) {
      for (final (name, value) in init) {
        builder.add(name, value);
      }
    }

    return builder;
  }

  /// Remove a header for [name].
  void remove(String name);

  /// Remove headers for where test.
  void removeWhere(bool Function(String name, String value) test);

  /// Adds a new header.
  void add(String name, String value);

  /// Building [Headers].
  Headers toHeaders();
}

final class _HeadersBuilderImpl implements HeadersBuilder {
  final locals = <(String, String)>[];

  @override
  void add(String name, String value) {
    if (name.isNotEmpty && value.isNotEmpty) {
      locals.add((name.toLowerCase(), value));
    }
  }

  @override
  void remove(String name) {
    final normalizedName = name.toLowerCase();
    removeWhere((name, _) => name.toLowerCase() == normalizedName);
  }

  @override
  void removeWhere(bool Function(String name, String value) test) {
    locals.removeWhere((element) => test(element.$1, element.$2));
  }

  @override
  Headers toHeaders() => Headers(locals);
}

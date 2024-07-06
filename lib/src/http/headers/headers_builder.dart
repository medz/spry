import 'headers.dart';

abstract interface class HeadersBuilder {
  factory HeadersBuilder([Iterable<(String, String)>? init]) {
    final builder = _HeadersBuilderImpl();

    if (init != null && init.isNotEmpty) {
      for (final (name, value) in init) {
        builder.add(name, value);
      }
    }

    return builder;
  }

  void remove(String name);
  void add(String name, String value);
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
    locals.removeWhere((element) => element.$1 == normalizedName);
  }

  @override
  Headers toHeaders() => Headers(locals);
}

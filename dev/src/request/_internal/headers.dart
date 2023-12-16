part of '../request_event.dart';

extension on HttpHeaders {
  static const _key = ContainerKey<Headers>(#spry._internal.headers);

  Headers returnsOrCreate(Container container) {
    final existing = container.get(_key);
    if (existing != null) return existing;

    final headers = Headers();
    forEach((name, values) {
      for (final value in values) {
        headers.append(name, value);
      }
    });

    container.set(_key, value: headers);

    return headers;
  }
}

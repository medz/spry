part of '../request_event.dart';

extension on HttpHeaders {
  Headers returnsOrCreate(ProvideInject store) {
    if (store.contains(this)) {
      return store.inject(this);
    }

    final headers = Headers();
    forEach((name, values) {
      for (final value in values) {
        headers.append(name, value);
      }
    });

    store.provide(this, () => headers);

    return headers;
  }
}

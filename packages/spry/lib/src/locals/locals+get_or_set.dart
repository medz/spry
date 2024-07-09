// ignore_for_file: file_names

import 'locals.dart';

extension LocalsGetOrSet on Locals {
  /// Gets or set a type of [T] value from [key].
  ///
  /// If the value type is not [T], using [creates] value set it.
  T getOrSet<T>(Object key, T Function() creates) {
    try {
      return get<T>(key);
    } catch (_) {
      final value = creates();
      set(key, value);

      return value;
    }
  }
}

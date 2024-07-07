// ignore_for_file: file_names

import 'locals.dart';

extension LocalsGetOrSet on Locals {
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

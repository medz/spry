// ignore_for_file: file_names

import 'locals.dart';

extension LocalsGetOrNull on Locals {
  /// Gets a type of [T] value for [key], If value type is not [T] returns null.
  T? getOrNull<T>(Object key) {
    try {
      return get<T>(key);
    } catch (_) {
      return null;
    }
  }
}

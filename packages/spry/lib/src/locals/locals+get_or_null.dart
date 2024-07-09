// ignore_for_file: file_names

import 'locals.dart';

extension LocalsGetOrNull on Locals {
  T? getOrNull<T>(Object key) {
    try {
      return get<T>(key);
    } catch (_) {
      return null;
    }
  }
}

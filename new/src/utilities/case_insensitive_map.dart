import 'package:collection/collection.dart';

/// Ignore [Map] whose keys are [String] case.
class CaseInsensitiveMap<T> extends CanonicalizedMap<String, String, T> {
  static String _canonicalizeKey(String key) => key.toLowerCase();

  CaseInsensitiveMap() : super(_canonicalizeKey);
  CaseInsensitiveMap.from(Map<String, T> other)
      : super.from(other, _canonicalizeKey);
}

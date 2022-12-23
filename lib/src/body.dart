import 'dart:convert';

abstract class Body {
  /// Get the body of a [Stream<List<int>>].
  Stream<List<int>> stream();

  /// Get the body of a [String].
  Future<String> text({Encoding encoding = utf8});

  /// Get the body of a [List<int>].
  Future<List<int>> raw({Encoding encoding = utf8});
}

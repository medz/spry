import 'dart:convert';

import '../body.dart';

class InternalBody implements Body {
  const InternalBody(Stream<List<int>> stream) : _stream = stream;

  final Stream<List<int>> _stream;

  @override
  Stream<List<int>> stream() => _stream;

  @override
  Future<String> text({Encoding encoding = utf8}) =>
      encoding.decodeStream(_stream);

  @override
  Future<List<int>> raw({Encoding encoding = utf8}) =>
      text(encoding: encoding).then((String text) => encoding.encode(text));
}

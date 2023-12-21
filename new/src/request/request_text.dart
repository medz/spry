import 'dart:convert';

import 'request.dart';

extension RequestText on Request {
  /// the body as string
  Future<String> text([Encoding encoding = utf8]) =>
      encoding.decodeStream(stream());
}

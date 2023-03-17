/// The library for parsing and encoding URL-encoded strings.
library spry.urlencoded;

import 'dart:io';

import 'package:meta/meta.dart';

import 'src/request.dart';
import 'src/response.dart';

extension SpryRequestUrlencoded on Request {
  /// Stores the parsed URL-encoded body in the request context under this key.
  @internal
  @protected
  static const Symbol key = #SpryRequestUrlencodedParsedBody;

  /// Returns a map of the key-value pairs in the given URL-encoded string.
  @useResult
  Future<Map<String, String>> urlencoded() async {
    // If parsed body is already available, return it.
    final Map<String, String>? parsedBody = context[key];
    if (parsedBody != null) {
      return parsedBody;
    }

    // Parse the body and store it in the context.
    return context[key] = Uri.splitQueryString((await text()).trim());
  }
}

extension SpryResponseUrlencoded on Response {
  /// The content type for URL-encoded strings.
  @internal
  @protected
  static final ContentType contentType =
      ContentType.parse('application/x-www-form-urlencoded');

  /// Writes the given map of key-value pairs as a URL-encoded string.
  void urlencoded(Map<String, String> value) {
    this
      ..contentType = contentType
      ..text(Uri(queryParameters: value).query);
  }
}

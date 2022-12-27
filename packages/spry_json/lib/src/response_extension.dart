import 'dart:convert';
import 'dart:io';

import 'package:spry/spry.dart';
import 'package:spry_json/src/spry_json.dart';

/// The spry [Response] JSON extension.
extension SpryResponseJsonExtension on Response {
  /// Send a JSON response.
  ///
  /// ```dart
  /// import 'package:spry/spry.dart';
  ///
  /// handler(Context context) {
  ///  context.response.json({'foo': 'bar'});
  /// })
  /// ```
  ///
  /// The [toEncodable] parameter see [JsonCodec]
  void json(Object? object, {Object? Function(dynamic)? toEncodable}) {
    final SpryJson json = SpryJson.of(context);

    // If response not set [encoding], use [SpryJson.encoding].
    encoding ??= json.encoding;

    // Set content type.
    headers.contentType = json.contentType ?? ContentType.json;

    // final Encoding encoding = this.encoding ?? spryJson.encoding ?? utf8;
    final String body = json.encode(object, toEncodable: toEncodable);

    // Send encoded body.
    return send(body);
  }
}

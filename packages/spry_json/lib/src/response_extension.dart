import 'dart:convert';
import 'dart:io';

import 'package:spry/extensions.dart';
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
    final Encoding encoding = context.app.encoding;

    final String body = json.encode(object, toEncodable: toEncodable);
    final List<int> bytes = encoding.encode(body);

    contentType(ContentType.json);
    raw(bytes);
  }
}

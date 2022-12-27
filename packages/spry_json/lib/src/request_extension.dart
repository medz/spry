import 'dart:convert';

import 'package:spry/spry.dart';

import '../constant.dart';
import 'spry_json.dart';

/// Spry [Request] JSON extension.
extension SpryRequestJsonExtension on Request {
  /// Read the [Request] body as a JSON object.
  ///
  /// ```dart
  /// import 'package:spry/spry.dart';
  ///
  /// handler(Context context) {
  ///   final json = context.request.json();
  ///   // ...
  /// }
  /// ```
  Future<dynamic> json() async {
    if (context.contains(SPRY_REQUEST_JSON_BODY)) {
      return context.get(SPRY_REQUEST_JSON_BODY);
    }

    // Get the [SpryJson] instance from the [Context].
    final SpryJson json = SpryJson.of(context);

    // Get string encoding.
    final Encoding encoding = json.encoding ?? utf8;

    // Read the [Request] body as a string.
    final String body = await encoding.decodeStream(this.body);

    try {
      final dynamic jsonBody = json.decode(body);
      context.set(SPRY_REQUEST_JSON_BODY, jsonBody);

      return jsonBody;
    } catch (e) {
      if (!json.hijackParseError) {
        rethrow;
      }
    }

    return null;
  }
}

import 'dart:convert';

import 'package:spry/spry.dart';

import 'spry_json.dart';

/// Spry [Request] JSON extension.
extension SpryRequestJsonExtension on Request {
  /// Read the [Request] body as a JSON object.
  ///
  /// ```dart
  /// import 'package:spry/spry.dart';
  ///
  /// handler(Context context) async {
  ///   final json = await context.request.json();
  ///   // ...
  /// }
  /// ```
  Future<dynamic> get json async {
    // Get the [SpryJson] instance from the [Context].
    final SpryJson json = SpryJson.of(context);

    // Get string encoding.
    final Encoding encoding = json.encoding ?? utf8;

    try {
      final List<int> bytes = await raw();
      final String body = encoding.decode(bytes).trim();
      if (body.startsWith('{') || body.startsWith('[')) {
        return json.decode(body);
      }

      throw HttpException.unsupportedMediaType(
          "Only json objects or arrays are supported.");
    } catch (e, stackTrace) {
      if (e is HttpException) {
        rethrow;
      }

      throw HttpException.internalServerError(
          "Failed to parse json body: ${e.toString()}", stackTrace);
    }
  }
}

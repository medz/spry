library spry.urlencoded;

import 'dart:convert';

import 'package:spry/spry.dart';

/// Read the urlencoded map from the [Request].
extension SpryRequestUrlencoded on Request {
  /// Read the [Request] body as a urlencoded map.
  ///
  /// Each query component will be decoded using [encoding]. The default
  /// encoding is [Spry.encoding].
  ///
  /// ```dart
  /// final urlencoded = await context.request.urlencoded();
  /// ```
  Future<Map<String, String>> urlencoded({Encoding? encoding}) async {
    try {
      final String body = (await text()).trim();

      return Uri.splitQueryString(
        body,
        encoding: encoding ?? context.app.encoding,
      );
    } catch (e, stackTrace) {
      if (e is SpryHttpException) {
        rethrow;
      }

      throw SpryHttpException.internalServerError(
        message: "Failed to parse urlencoded body: ${e.toString()}",
        stackTrace: stackTrace,
      );
    }
  }
}

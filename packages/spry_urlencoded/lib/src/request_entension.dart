import 'dart:convert';

import 'package:spry/spry.dart';

import 'urlencoded.dart';

/// Read the urlencoded map from the [Request].
extension SpryUrlencodedExtension on Request {
  /// Read the [Request] body as a urlencoded map.
  ///
  /// Each query component will be decoded using [encoding]. The default
  /// encoding is [Urlencoded.part].
  ///
  /// ```dart
  /// final urlencoded = await context.request.urlencoded();
  /// ```
  Future<Map<String, String>> urlencoded({Encoding? encoding}) async {
    // Get the urlencoded instance from the context.
    final Urlencoded urlencoded = Urlencoded.of(context);

    try {
      final List<int> bytes = await raw();
      final String body = urlencoded.string.decode(bytes).trim();

      return Uri.splitQueryString(body, encoding: encoding ?? urlencoded.part);
    } catch (e, stackTrace) {
      if (e is HttpException) {
        rethrow;
      }

      throw HttpException.internalServerError(
          "Failed to parse urlencoded body: ${e.toString()}", stackTrace);
    }
  }
}

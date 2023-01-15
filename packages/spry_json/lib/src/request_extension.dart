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

    try {
      final String body = (await text()).trim();
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

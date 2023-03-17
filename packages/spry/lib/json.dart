library spry.json;

import 'dart:convert';
import 'dart:io';

import 'src/request.dart';
import 'src/response.dart';
import 'src/spry_http_exception.dart';

extension SpryRequestJSON on Request {
  /// Internal and protected parsed JSON object stored in the [Context] under
  /// the key.
  static const Symbol key = #SpryRequestJsonParsedResult;

  /// Returns the JSON object of the request body.
  ///
  /// The optional [reviver] function is called once for each object or list
  /// property that has been parsed during decoding. The `key` argument is either
  /// the integer list index for a list property, the string map key for object
  /// properties, or `null` for the final result.
  ///
  /// The default [reviver] (when not provided) is the identity function.
  Future<dynamic> json({
    Object? Function(Object?, Object?)? reviver,
    Encoding? encoding,
  }) async {
    // If the JSON object has already been parsed, return it.
    if (context.contains(key)) return context[key];

    final source = (await text(encoding: encoding)).trim();
    try {
      return context[key] = jsonDecode(source, reviver: reviver);
    } catch (e, stackTrace) {
      throw SpryHttpException.internalServerError(
        message: "Failed to parse json body: ${e.toString()}",
        stackTrace: stackTrace,
        uri: uri,
      );
    }
  }
}

extension SpryResponseJson on Response {
  /// Write a JSON object to the response body.
  ///
  /// The optional [toEncodable] function is called for any non-primitive object
  /// that is to be encoded. If [toEncodable] is omitted, it defaults to a
  /// function that returns the result of calling `.toJson()` on the object.
  void json(
    Object? object, {
    Object? Function(Object? nonSerializable)? toEncodable,
    Encoding? encoding,
  }) {
    contentType = ContentType.json;
    encoding ??= context.app.encoding;

    return raw(encoding.encode(jsonEncode(object, toEncodable: toEncodable)));
  }
}

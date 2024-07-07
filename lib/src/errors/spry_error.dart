import 'dart:convert';

import '../http/headers/headers.dart';
import '../http/response.dart';

class SpryError extends Error {
  SpryError._(this.message, [this.response]);
  SpryError.response(this.message, Response this.response);

  factory SpryError(
    String message, {
    int status = 200,
    String? statusText,
    Headers headers = const Headers(),
    Encoding encoding = utf8,
  }) {
    final response = Response.text(
      message,
      status: status,
      statusText: statusText,
      headers: headers,
    );

    return SpryError._(message, response);
  }

  final String message;
  final Response? response;
}

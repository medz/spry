import 'dart:convert';
import 'dart:typed_data';

import 'http_message/http_message.dart';
import 'headers.dart';
import 'http_status_reason_phrase.dart';

/// HTTP Response.
abstract interface class Response implements HttpMessage {
  /// Response status.
  int get status;

  /// Response status HTTP reason phrase.
  String get statusText;

  /// Creates a RAW stream response.
  factory Response(
    Stream<Uint8List>? body, {
    int status,
    String? statusText,
    Headers? headers,
    Encoding encoding,
  }) = _ResponseImpl;

  /// Creates a redirect response.
  factory Response.redirect(
    Uri location, {
    int status = 307,
    String? statusText,
    Headers? headers,
    Encoding encoding = utf8,
  }) {
    assert(status >= 300 && status <= 308,
        'Redirect status must be between 300 and 308');

    return Response(null,
        status: status,
        statusText: statusText,
        headers: headers,
        encoding: encoding)
      ..headers.set('Location', location.toString());
  }

  /// Creates a text response.
  factory Response.text(
    String body, {
    int status = 200,
    String? statusText,
    Headers? headers,
    Encoding encoding = utf8,
  }) {
    final bytes = switch (encoding.encode(body)) {
      final Uint8List value => value,
      final List<int> bytes => Uint8List.fromList(bytes),
    };

    return Response(Stream<Uint8List>.value(bytes),
        status: status,
        statusText: statusText,
        headers: headers,
        encoding: encoding)
      ..headers.set('Content-Length', bytes.lengthInBytes.toString())
      ..headers.set('Content-Type', 'text/plain; charset=${encoding.name}');
  }

  /// Creates a JSON response.
  factory Response.json(
    Object? body, {
    int status = 200,
    String? statusText,
    Headers? headers,
    Encoding encoding = utf8,
  }) {
    return Response.text(json.encode(body),
        status: status,
        statusText: statusText,
        headers: headers,
        encoding: encoding)
      ..headers
          .set('Content-Type', 'application/json; charset=${encoding.name}');
  }
}

/// Internal response impl.
class _ResponseImpl implements Response {
  _ResponseImpl(
    this.body, {
    this.status = 200,
    String? statusText,
    Headers? headers,
    this.encoding = utf8,
  })  : statusReasonPhrase = statusText,
        headers = headers ?? Headers();

  final String? statusReasonPhrase;

  @override
  final Stream<Uint8List>? body;

  @override
  final Encoding encoding;

  @override
  Headers headers;

  @override
  final int status;

  @override
  String get statusText => statusReasonPhrase ?? status.httpStatusReasonPhrase;
}

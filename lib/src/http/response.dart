import 'dart:convert';
import 'dart:typed_data';

import 'headers.dart';
import 'http_message.dart';
import 'http_status_reason_phrase.dart';

/// Spry response interface.
abstract interface class Response implements HttpMessage {
  /// Creates a new [Response].
  factory Response(
    Stream<Uint8List>? body, {
    int status,
    String? statusText,
    Headers? headers,
  }) = _ResponseImpl;

  /// Creates a new [Response] from text.
  factory Response.text(
    String body, {
    int status = 200,
    String? statusText,
    Headers? headers,
  }) {
    final bytes = utf8.encode(body);
    final response = Response(
      Stream.value(bytes),
      status: status,
      statusText: statusText,
      headers: headers,
    );

    response.headers
      ..set('content-length', bytes.lengthInBytes.toString())
      ..set('content-type', 'text/plain');

    return response;
  }

  /// Creates a new [Response] from JSON.
  factory Response.json(
    Object? body, {
    int status = 200,
    String? statusText,
    Headers? headers,
  }) {
    final response = Response.text(
      json.encode(body),
      status: status,
      statusText: statusText,
      headers: headers,
    );

    return response..headers.set('content-type', 'application/json');
  }

  /// Create redirect response.
  factory Response.redirect(
    Uri location, {
    int status = 307,
    String? statusText,
    Headers? headers,
  }) {
    const allowStatus = [300, 301, 302, 303, 304, 305, 306, 307, 308];
    assert(allowStatus.contains(status),
        'Redirect status only allow ${allowStatus.join(', ')}');

    return Response(null,
        status: status, statusText: statusText, headers: headers);
  }

  /// Response status.
  int get status;

  /// Response status code reason phrases.
  String get statusText;
}

final class _ResponseImpl extends HttpMessage implements Response {
  _ResponseImpl(
    this.body, {
    this.status = 200,
    String? statusText,
    Headers? headers,
  })  : statusReasonPhrase = statusText,
        headers = headers ?? Headers();

  final String? statusReasonPhrase;

  @override
  final int status;

  @override
  late final Headers headers;

  @override
  final Stream<Uint8List>? body;

  @override
  String get statusText => statusReasonPhrase ?? status.httpStatusReasonPhrase;
}

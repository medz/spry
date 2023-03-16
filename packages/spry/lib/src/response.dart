import 'dart:convert';
import 'dart:io';

import '_internal/eager_response.dart';
import 'context.dart';

/// Spry framework response.
class Response {
  Response({
    required this.context,
    required this.httpResponse,
  });

  //---------------------------------------------------------------------
  // Internal properties
  //---------------------------------------------------------------------
  Stream<List<int>>? _bodyStream;
  //---------------------------------------------------------------------

  /// The [Context] instance of the current request.
  final Context context;

  /// The raw [HttpResponse] instance of the current request.
  final HttpResponse httpResponse;

  /// The status code of the response.
  ///
  /// Any integer value is accepted. For
  /// the official HTTP status codes use the fields from
  /// [HttpStatus]. If no status code is explicitly set the default
  /// value [HttpStatus.ok] is used.
  ///
  /// The status code must be set before the body is written
  /// to. Setting the status code after writing to the response body or
  /// closing the response will throw a `StateError`.
  int statusCode = HttpStatus.ok;

  /// Returns the response headers.
  ///
  /// The response headers can be modified until the response body is
  /// written to or closed. After that they become immutable.
  HttpHeaders get headers => httpResponse.headers;

  /// Returns the response cookies.
  final cookies = <Cookie>[];

  /// Returns the [ContentType] of the response.
  ContentType get contentType => headers.contentType ?? ContentType.text;

  /// Sets the [ContentType] of the response.
  set contentType(ContentType contentType) => headers.contentType = contentType;

  /// Sets the status code of the response.
  @Deprecated('Use `statusCode` instead.')
  void status(int statusCode) {
    this.statusCode = statusCode;
  }

  /// Redirects the response to the given [url].
  Future<void> redirect(
    Uri location, {
    int status = HttpStatus.movedTemporarily,
  }) {
    return httpResponse.redirect(location, status: status).then((_) {
      context[responseIsClosed] = true;
    });
  }

  /// Close the response.
  ///
  /// Should be called after sending the response, we don't recommend you to call it.
  /// Because it is eager, it will end the request as soon as it is called, which is a disaster for post middleware.
  Future<void> close() async {
    final next = context[eagerResponseWriter];
    if (next is Function) {
      return next();
    }

    await httpResponse.close();
  }

  /// Return the response body as a [Stream].
  ///
  /// If body is not ready, it will return `null`.
  Stream<List<int>>? read() => _bodyStream;

  /// Send a [Stream] of bytes as the response body.
  void stream(Stream<List<int>> stream) => _bodyStream = stream;

  /// Send a [List<int>] RAW data as the response body.
  void raw(List<int> raw) => stream(Stream.value(raw));

  /// Send a [String] as the response body.
  ///
  /// If [encoding] is not specified, it will use [Spry.encoding] as the default encoding.
  void text(String text, {Encoding? encoding}) {
    encoding ??= context.app.encoding;
    raw(encoding.encode(text));

    if (context['responseIsClosed'] != true) {
      contentType = ContentType.text;
    }
  }
}

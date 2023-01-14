import 'dart:convert';
import 'dart:io';

import 'context.dart';

abstract class Response {
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
  HttpHeaders get headers;

  /// Returns the response cookies.
  List<Cookie> get cookies;

  /// Sets the content type of the response.
  void contentType(ContentType contentType) {
    headers.contentType = contentType;
  }

  /// Sets the status code of the response.
  void status(int statusCode) {
    this.statusCode = statusCode;
  }

  /// The [Context] of the response.
  Context get context;

  /// Redirects the response to the given [url].
  Future<void> redirect(Uri location,
      {int status = HttpStatus.movedTemporarily});

  /// Close the response.
  ///
  /// Should be called after sending the response, we don't recommend you to call it.
  /// Because it is eager, it will end the request as soon as it is called, which is a disaster for post middleware.
  Future<void> close();

  /// Return the response body as a [Stream].
  ///
  /// If body is not ready, it will return `null`.
  Stream<List<int>>? read();

  /// Send a [Stream] of bytes as the response body.
  void stream(Stream<List<int>> stream);

  /// Send a [List<int>] RAW data as the response body.
  void raw(List<int> raw);

  /// Send a [String] as the response body.
  ///
  /// If [encoding] is not specified, it will use [Spry.encoding] as the default encoding.
  void text(String text, {Encoding? encoding});
}

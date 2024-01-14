import 'dart:io';

import 'package:webfetch/webfetch.dart';

import 'abort_exception.dart';

class Abort implements AbortException {
  @override
  late final String message;

  @override
  final int status;

  /// Creates a new http status abort exception
  ///
  /// - [status] is the http status code.
  /// - [message] is the message describing the abort.
  ///
  /// ```dart
  /// throw Abort(HttpStatus.notFound, message: 'Page not found');
  /// ```
  Abort(this.status, {String? message}) {
    this.message = message ?? status.httpReasonPhrase;
  }

  /// Creates a new redirecting exception.
  ///
  /// ```
  /// throw Abort.redirect('/login');
  /// ```
  static Never redirect(
    String location, {
    int status = HttpStatus.movedTemporarily,
    String? message,
    String method = "GET",
  }) {
    final info = _RedirectInfo(
      method: method.toLowerCase(),
      statusCode: status,
      location: Uri.parse(location),
    );

    throw RedirectException(message ?? status.httpReasonPhrase, [info]);
  }
}

class _RedirectInfo implements RedirectInfo {
  @override
  final Uri location;

  @override
  final String method;

  @override
  final int statusCode;

  const _RedirectInfo({
    required this.location,
    required this.statusCode,
    required this.method,
  });
}

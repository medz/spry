import 'dart:io';

import 'interceptor/rethrow_exception.dart';

/// Redirect response.
///
/// If you want to throw [RedirectResponse] in your [Middleware] or [Handler] to
/// redirect the request, you can use this class.
class RedirectResponse implements RethrowException {
  /// Create an instance of [RedirectResponse].
  const RedirectResponse._(this.location,
      {this.status = HttpStatus.movedTemporarily});

  /// Throws an [RedirectResponse] exception.
  factory RedirectResponse(Uri location,
          {int status = HttpStatus.movedTemporarily}) =>
      throw RedirectResponse._(location, status: status);

  /// The location to redirect to.
  final Uri location;

  /// The status code of the response.
  final int status;
}

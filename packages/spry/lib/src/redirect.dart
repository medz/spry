import 'dart:async';
import 'dart:io';

import 'context.dart';
import 'interceptor/exception_filter.dart';

/// Redirect response.
///
/// If you want to throw [RedirectResponse] in your [Middleware] or [Handler] to
/// redirect the request, you can use this class.
class RedirectResponse implements Exception {
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

/// Redirect response filter.
class RedirectResponseFilter extends ExceptionFilter<RedirectResponse> {
  const RedirectResponseFilter();

  @override
  FutureOr<void> handler(
      Context context, RedirectResponse exception, StackTrace stack) async {
    await response(context)
        .redirect(exception.location, status: exception.status);
  }

  /// Returns the [HttpResponse] of the [context].
  HttpResponse response(Context context) => context.response.httpResponse;
}

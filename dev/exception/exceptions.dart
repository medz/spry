import 'dart:io';

import '../_internal/iterable_utils.dart';
import 'abort.dart';
import 'abort_exception.dart';
import 'exception_filter.dart';
import 'exception_source.dart';
import 'exceptions_builder.dart';

class Exceptions extends Iterable<ExceptionFilter>
    implements ExceptionsBuilder, ExceptionFilter {
  Exceptions();

  /// Inner list of filters.
  final _filters = <ExceptionFilter>[];

  @override
  void addFilter<T>(ExceptionFilter<T> filter) => _filters.add(filter);

  @override
  Iterator<ExceptionFilter> get iterator => _filters.iterator;

  /// Clears all filters.
  void clear() => _filters.clear();

  @override
  Future<void> process(ExceptionSource source, HttpRequest request) async {
    final filter = firstWhereOrNull((element) => element.matches(source));
    if (filter != null) {
      return filter.process(source, request);
    }

    return switch (source.exception) {
      RedirectException e => handleRedirect(source.cast(e), request),
      AbortException e => handleAbort(source.cast(e), request),
      Error e => handleAbort(
          source.cast(Abort(HttpStatus.internalServerError,
              message: Error.safeToString(e))),
          request),
      Exception e => handleAbort(
          source.cast(
              Abort(HttpStatus.internalServerError, message: e.toString())),
          request),
      _ => handleAbort(
          source.cast(Abort(HttpStatus.internalServerError)),
          request,
        ),
    };
  }
}

extension on Exceptions {
  Future<void> handleRedirect(
    ExceptionSource<RedirectException> source,
    HttpRequest request,
  ) async {
    if (source.exception.redirects.isEmpty) {
      return process(
        source.cast(Abort(HttpStatus.internalServerError)),
        request,
      );
    }

    final response = request.response;
    final info = source.exception.redirects.last;

    await response.redirect(info.location, status: info.statusCode);
  }

  Future<void> handleAbort(
    ExceptionSource<AbortException> source,
    HttpRequest request,
  ) async {
    final response = request.response;
    if (source.isResponseClosed) return;

    response.statusCode = source.exception.status;
  }
}

extension<T> on ExceptionFilter<T> {
  /// Matches the exception type.
  bool matches(ExceptionSource source) => source.exception is T;
}

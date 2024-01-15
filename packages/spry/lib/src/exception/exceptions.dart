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

  @override
  Future<void> process(ExceptionSource source, HttpRequest request) async {
    final filter = firstWhereOrNull((element) => element.matches(source));
    if (filter != null) {
      try {
        return filter.process(source, request);
      } catch (e) {
        return defaultProcess(source.cast(e), request);
      }
    }

    return defaultProcess(source, request);
  }
}

extension on Exceptions {
  Future<void> defaultProcess(
    ExceptionSource source,
    HttpRequest request,
  ) {
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
    response.write(source.exception.message);
  }
}

extension<T> on ExceptionFilter<T> {
  /// Matches the exception type.
  bool matches(ExceptionSource source) => source.exception is T;
}

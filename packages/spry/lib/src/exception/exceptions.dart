import 'dart:io';

import '../_internal/iterable_utils.dart';
import '../application.dart';
import 'abort.dart';
import 'abort_exception.dart';
import 'exception_filter.dart';
import 'exception_source.dart';
import 'exceptions_builder.dart';
import 'returow_exception.dart';

class Exceptions extends Iterable<ExceptionFilter>
    implements ExceptionsBuilder, ExceptionFilter {
  Exceptions(Application application) : _application = application;

  /// Inner list of filters.
  final _filters = <ExceptionFilter>[];

  final Application _application;

  @override
  void addFilter<T>(ExceptionFilter<T> filter) => _filters.add(filter);

  @override
  Iterator<ExceptionFilter> get iterator => _filters.iterator;

  @override
  Future<void> process(ExceptionSource source, HttpRequest request) async {
    return await handle(this, source, request);
  }
}

extension on Exceptions {
  Future<void> handle(Iterable<ExceptionFilter> filters, ExceptionSource source,
      HttpRequest request) async {
    final filter =
        filters.firstWhereOrNull((element) => element.matches(source));
    if (filter == null) {
      return defaultProcess(source, request);
    }

    try {
      return await filter.process(source, request);
    } on RethrowException {
      final withoutFilters = filters.skipWhile((element) => element == filter);

      return await handle(withoutFilters, source, request);
    } catch (error, stackTrace) {
      _application.logger.severe(
          'Exception thrown while processing request', error, stackTrace);

      return await defaultProcess(source, request);
    }
  }

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

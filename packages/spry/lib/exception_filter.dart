import 'dart:async';

import 'spry.dart';

class ExceptionSource<T> {
  const ExceptionSource(this.exception, this.stackTrace);

  final T exception;
  final StackTrace stackTrace;
}

abstract interface class ExceptionFilter<T> {
  Future<Response> process(Event event, ExceptionSource<T> source);
}

Future<Response> Function(Event event) defineExceptionFilter<T>(
    FutureOr<Response> Function(Event event, ExceptionSource<T> source)
        process) {
  return (Event event) async {
    try {
      return await next(event);
    } catch (exception, stackTrace) {
      if (exception is T) {
        return process(event, ExceptionSource(exception as T, stackTrace));
      } else if (exception is Response) {
        return exception;
      }

      rethrow;
    }
  };
}

Future<Response> Function(Event event) withExceptionFilter<T>(
    ExceptionFilter<T> filter) {
  return defineExceptionFilter(filter.process);
}

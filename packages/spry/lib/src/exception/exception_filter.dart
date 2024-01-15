import 'dart:io';

import 'exception_source.dart';

abstract interface class ExceptionFilter<T> {
  Future<void> process(ExceptionSource<T> source, HttpRequest request);
}

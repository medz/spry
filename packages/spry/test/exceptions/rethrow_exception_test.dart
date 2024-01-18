import 'dart:io';

import 'package:spry/spry.dart';
import 'package:test/test.dart';

import '../_internal/test_request.dart';

class _Filter1 implements ExceptionFilter<Exception> {
  @override
  Future<void> process(ExceptionSource<Exception> source, HttpRequest request) {
    if (source.exception is _Exception) {
      throw const RethrowException();
    }

    fail('Exception was not rethrown');
  }
}

class _Filter2 implements ExceptionFilter<_Exception> {
  @override
  Future<void> process(
      ExceptionSource<_Exception> source, HttpRequest request) async {}
}

class _Exception implements Exception {}

void main() {
  late final Application app;
  late final HttpRequest request;

  setUp(() {
    app = Application.late();
    request = TestRequest();

    app.exceptions.addFilter(_Filter1());
    app.exceptions.addFilter(_Filter2());
  });

  test('rethrow exception', () async {
    final exception = _Exception();
    final source = ExceptionSource(
      exception: exception,
      stackTrace: StackTrace.empty,
      responseClosedFactory: () => true,
    );

    await app.exceptions.process(source, request);
  });
}

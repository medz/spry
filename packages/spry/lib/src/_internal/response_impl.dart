import 'dart:convert';
import 'dart:io';

import '../context.dart';
import '../response.dart';
import '../extensions/app_extension.dart';
import 'eager_response.dart';

class ResponseImpl extends Response {
  /// Creates a new [ResponseImpl] instance.
  ResponseImpl(this.response);

  @override
  late final Context context;

  /// [HttpResponse] instance.
  final HttpResponse response;

  @override
  final List<Cookie> cookies = [];

  Stream<List<int>>? _bodyStream;

  @override
  HttpHeaders get headers => response.headers;

  @override
  Future<void> close() async {
    final next = context.get(eagerResponseWriter);
    if (next is Function) {
      return next();
    }

    await response.close();
  }

  @override
  Future<void> redirect(Uri location,
      {int status = HttpStatus.movedTemporarily}) async {
    await response.redirect(location, status: status);
  }

  @override
  Stream<List<int>>? read() => _bodyStream;

  @override
  void stream(Stream<List<int>> stream) {
    _bodyStream = stream;
  }

  @override
  void raw(List<int> raw) {
    final stream = Stream<List<int>>.value(raw);

    return this.stream(stream);
  }

  @override
  void text(String text, {Encoding? encoding}) {
    encoding ??= context.app.encoding;

    this
      ..contentType(ContentType.text)
      ..raw(encoding.encode(text));
  }
}

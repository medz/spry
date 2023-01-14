import 'dart:io';

import 'package:spry/src/context.dart';

import '../request.dart';

class RequestImpl extends Request {
  /// [HttpRequest] instance.
  final HttpRequest request;

  /// Creates a new [RequestImpl] instance.
  RequestImpl(this.request);

  @override
  List<Cookie> get cookies => request.cookies;

  @override
  HttpHeaders get headers => request.headers;

  @override
  bool get isEmpty => request.contentLength == 0;

  @override
  String get method => request.method;

  @override
  String get protocolVersion => request.method;

  @override
  Uri get requestedUri => request.requestedUri;

  @override
  Uri get uri => request.uri;

  @override
  late final Context context;

  @override
  Future<List<int>> raw() async {
    final List<List<int>> parts = await request.toList();
    final List<int> raw = parts.expand((List<int> part) => part).toList();

    return raw;
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:spry/src/context.dart';

import '../request.dart';

class RequestImpl extends Request {
  /// [HttpRequest] instance.
  final HttpRequest request;

  /// Creates a new [RequestImpl] instance.
  RequestImpl(this.request);

  @override
  Stream<Uint8List> get body => request;

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
}

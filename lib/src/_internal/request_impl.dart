import 'dart:io';
import 'dart:typed_data';

import '../request.dart';

class RequestImpl implements Request {
  @override
  Stream<Uint8List> get body => request;

  @override
  String? get charset => request.headers.contentType?.charset;

  @override
  HttpHeaders get headers => request.headers;

  @override
  String get host => throw UnimplementedError();

  @override
  String get ip => throw UnimplementedError();

  @override
  Iterable<String> get ips => throw UnimplementedError();

  @override
  int get length => request.contentLength;

  @override
  String get method => request.method;

  @override
  String get protocol => throw UnimplementedError();

  @override
  bool get secure => protocol.toLowerCase() == 'https';

  @override
  String? get type => request.headers.contentType?.mimeType;

  @override
  Uri get uri => request.uri;

  /// [HttpRequest] instance.
  final HttpRequest request;

  /// Creates a new [RequestImpl] instance.
  const RequestImpl(this.request);
}

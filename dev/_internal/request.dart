import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../application.dart';

class SpryRequest extends Stream<Uint8List> implements HttpRequest {
  /// Resolve a [SpryRequest] from the given [request].
  static SpryRequest of(HttpRequest request) {
    if (request is SpryRequest) return request;
    throw StateError('Current request is not using Spry wrapped HttpRequest');
  }

  Stream<Uint8List> stream;

  final HttpRequest request;
  final Application application;
  final Map locals;

  /// Creates a new [SpryRequest] with the given [application], [request] and
  /// [stream].
  SpryRequest({
    required this.application,
    required this.request,
    required this.stream,
    required this.locals,
  });

  /// Creates a new [SpryRequest] with the given [application] and [request].
  factory SpryRequest.from({
    required Application application,
    required HttpRequest request,
  }) {
    if (request is SpryRequest) return request;

    return SpryRequest(
      application: application,
      request: request,
      stream: request,
      locals: {},
    );
  }

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  X509Certificate? get certificate => request.certificate;

  @override
  HttpConnectionInfo? get connectionInfo => request.connectionInfo;

  @override
  int get contentLength => request.contentLength;

  @override
  List<Cookie> get cookies => request.cookies;

  @override
  HttpHeaders get headers => request.headers;

  @override
  String get method => request.method;

  @override
  bool get persistentConnection => request.persistentConnection;

  @override
  String get protocolVersion => request.protocolVersion;

  @override
  Uri get requestedUri => request.requestedUri;

  @override
  HttpResponse get response => request.response;

  @override
  HttpSession get session => request.session;

  @override
  Uri get uri => request.uri;
}

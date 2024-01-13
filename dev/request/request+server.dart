// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import '../_internal/request.dart';
import '../application.dart';
import 'request+application.dart';

extension Request$Server on HttpRequest {
  /// The [HttpServer] instance that is handling this request.
  HttpServer get server => application.server.autoWrapRequests(application);
}

extension on HttpServer {
  HttpServer autoWrapRequests(Application application) {
    if (this is _WrappedServer) return this;

    final stream = map((request) {
      if (request is SpryRequest) return request;
      return SpryRequest.from(
        application: application,
        request: request,
      );
    });

    return _WrappedServer(server: this, stream: stream);
  }
}

class _WrappedServer extends Stream<HttpRequest> implements HttpServer {
  final HttpServer server;
  final Stream<SpryRequest> stream;

  const _WrappedServer({
    required this.server,
    required this.stream,
  });

  @override
  StreamSubscription<HttpRequest> listen(
    void Function(HttpRequest event)? onData, {
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
  bool get autoCompress => server.autoCompress;

  @override
  set autoCompress(bool value) => server.autoCompress = value;

  @override
  Duration? get idleTimeout => server.idleTimeout;

  @override
  set idleTimeout(Duration? value) => server.idleTimeout = value;

  @override
  String? get serverHeader => server.serverHeader;

  @override
  set serverHeader(String? name) => server.serverHeader = name;

  @override
  InternetAddress get address => server.address;

  @override
  Future close({bool force = false}) => server.close(force: force);

  @override
  HttpConnectionsInfo connectionsInfo() => server.connectionsInfo();

  @override
  HttpHeaders get defaultResponseHeaders => server.defaultResponseHeaders;

  @override
  int get port => server.port;

  @override
  set sessionTimeout(int timeout) => server.sessionTimeout = timeout;
}

import 'dart:async';
import 'dart:io';

import '../../_io_utils.dart';
import '../../http/request.dart';
import '../../http/response.dart';
import '../server.dart';

class RuntimeServer extends Server<HttpServer, HttpRequest> {
  RuntimeServer(super.options) {
    final completer = Completer<void>();
    future = completer.future;

    void handler(HttpRequest httpRequest) {
      final request = _Request(httpRequest);
      final response = httpRequest.response;
      unawaited(Future.sync(() async {
        final Response(:status, :headers, :body) = await fetch(request);

        response.statusCode = status;
        for (final (name, value) in headers) {
          response.headers.add(name, value);
        }
        await response.addStream(body);
        await response.close();
      }));
    }

    completer.complete(Future.sync(() async {
      runtime = await HttpServer.bind(
        options.hostname ?? 'localhost',
        options.port ?? 0,
        shared: options.reusePort,
      );
      runtime.listen(handler);
    }));
  }

  late final Future<void> future;

  @override
  late final HttpServer runtime;

  @override
  Future<void> ready() => future;

  @override
  Future<void> close({bool force = true}) async {
    await runtime.close();
  }

  @override
  String? get hostname => runtime.address.host;

  @override
  int? get port => runtime.port;

  @override
  String? remoteAddress(HttpRequest request) {
    final info = request.connectionInfo;
    if (info == null) {
      return null;
    }

    final addr = info.remoteAddress.type == InternetAddressType.IPv6
        ? '[${info.remoteAddress.host}]'
        : info.remoteAddress.host;

    return '$addr:${info.remotePort}';
  }
}

class _Request extends Request {
  _Request(HttpRequest request)
      : super(
          method: request.method,
          url: request.requestedUri,
          headers: request.headers.toSpryHeaders(),
          body: request,
          runtime: request,
        );
}

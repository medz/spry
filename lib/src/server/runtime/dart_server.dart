import 'dart:async';
import 'dart:io';

import '../../http/headers.dart';
import '../../http/request.dart';
import '../../http/response.dart';
import '../server.dart';

class RuntimeServer extends Server {
  RuntimeServer(super.options);

  @override
  late final HttpServer runtime;

  @override
  Future<void> ready() async {
    runtime = await HttpServer.bind(
      options.hostname,
      options.port,
      shared: options.reusePort,
    );
    runtime.listen(handler);
  }

  @override
  Future<void> close({bool force = true}) async {
    await runtime.close();
  }

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
}

class _Request extends Request {
  _Request(HttpRequest request)
      : super(
          method: request.method,
          url: request.requestedUri,
          headers: request.headers.toSpryHeaders(),
          body: request,
        );
}

extension on HttpHeaders {
  Headers toSpryHeaders() {
    final headers = Headers();
    forEach((name, values) {
      for (final value in values) {
        headers.add(name, value);
      }
    });

    return headers;
  }
}
